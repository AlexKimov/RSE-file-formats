from inc_noesis import *


def registerNoesisTypes():
    handle = noesis.register( \
        "Red Storm Bitmap (Rainbow six 1/2, Ghost Recon)", ".rsb")
    noesis.setHandlerTypeCheck(handle, rsbCheckType)
    noesis.setHandlerLoadRGBA(handle, rsbLoadRGBA)
    
    return 1

    
class RSBImage:
    def __init__(self, reader):
        self.reader = reader
        self.version = 0
        self.imageWidth = 0
        self.imageHeight = 0
        self.containsPalette = 0
        self.dxtType = -1
        self.bitsRed = 0
        self.bitsGreen = 0
        self.bitsBlue = 0
        self.bitsAlpha = 0
        self.imageDataPos = 0
        self.bitDepth = 0
        
    def readBitMask(self, filereader):
        self.bitsRed = filereader.readUInt()
        self.bitsGreen = filereader.readUInt()
        self.bitsBlue = filereader.readUInt()
        self.bitsAlpha = filereader.readUInt()  
        self.bitDepth = int((self.bitsRed + self.bitsGreen + self.bitsBlue + \
            self.bitsAlpha)/8)       
            
    def getPalettedImage(self, filereader):
        imageSize = self.imageWidth*self.imageHeight  
        
        palBuffer = filereader.getBuffer()[16:1040]
        indBuffer = filereader.getBuffer()[1040 : (imageSize + 1040)]    
        
        imageData = noesis.allocBytes(imageSize*4)
        
        for i in range(0, imageSize):
            indexPos = indBuffer[i]*4
            imageData[i*4 + 2] = palBuffer[indexPos]
            imageData[i*4 + 1] = palBuffer[indexPos + 1]
            imageData[i*4] = palBuffer[indexPos + 2]
            imageData[i*4 + 3] = \
                palBuffer[indexPos + 3] if (palBuffer[indexPos + 3] != 0) else 255
                
        return imageData          
        
    def getRGBAImage(self, filereader):
        # bit unpack tables
        #table2 = [0, 255] 
        #table16 = [0, 17, 34, 51, 68, 86, 102, 119, 136, 153, 170, 181, 204, \
        #    221, 238, 255]
        #table32 = [0, 8, 16, 25, 33, 41, 49, 58, 66, 74, 82, 90, 99, \
        #    107, 115, 123, 132, 140, 148, 156, 165, 173, 181, 189, 197, 206, \
        #    214, 222, 230, 239, 247, 255]
        #table64 = [0, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 45, 49, 53, \
        #    57, 61, 65, 69, 73, 77, 81, 85, 89, 93, 97, 101, 105, 109, 113, \
        #    117, 121, 125, 130, 134, 138, 142, 146, 150, 154, 158, 162, 166, \
        #    170, 174, 178, 182, 186, 190, 194, 198, 202, 206, 210, 215, 219, \
        #    223, 227, 231, 235, 239, 243, 247, 251, 255]  
          
        imageSize = self.imageWidth*self.imageHeight    
        imageDataPos = filereader.tell()
        
        # some RSB images contain 8 bit copy   
        if self.containsPalette == 1:
            # skip paletted image + bit mask (16 byte)
            if filereader.tell() == 16:
                imageDataPos = 1056 + imageSize
                filereader.seek(1024 + imageSize, NOESEEK_REL)
            self.readBitMask(filereader)  
 
        #print(int.from_bytes(imageBuffer[0 : 2], byteorder='little'))  

        imageEndPos = imageDataPos + imageSize*self.bitDepth        
        
        # get image from file
        imageBuffer = filereader.getBuffer()[imageDataPos:imageEndPos] 
        
        # if self.bitDepth != 3:       
            # imageData = noesis.allocBytes(imageSize*4) # RGBA8888 image buffer        
            # for i in range(0, imageSize):
                # if self.bitDepth == 4:
                   # imageData[i*4] = imageBuffer[i*4 + 2]
                   # imageData[i*4 + 1] = imageBuffer[i*4 + 1] 
                   # imageData[i*4 + 2] = imageBuffer[i*4 + 3]
                   # imageData[i*4 + 3] = imageBuffer[i*4 + 0] 
                # else: # unpack 16 bit data to RGBA8888                
                   # pixel = int.from_bytes(imageBuffer[i*2 : i*2 + 2], \
                       # byteorder = 'little')
                   # if self.bitsGreen == 6:# RGB 565             
                       # imageData[i*4 + 3] = 255
                       # imageData[i*4] = table32[(pixel >> 11) & 31] 
                       # imageData[i*4 + 1] = table64[(pixel >> 5) & 63] 
                       # imageData[i*4 + 2] = table32[pixel & 31]           
                   # elif self.bitsAlpha == 1:# RGB 5551               
                      # imageData[i*4 + 2] = table32[pixel & 31]  
                      # imageData[i*4 + 1] = table32[(pixel >> 5) & 31] 
                      # imageData[i*4 + 0] = table32[(pixel >> 10) & 31] 
                      # imageData[i*4 + 3] = table2[(pixel >> 15) & 1]
                   # else: # RGBA 4444  
                      # print("123")
                      # imageData[i*4 + 3] = table16[(pixel >> 12) & 15]             
                      # imageData[i*4 + 0] = table16[(pixel >> 8) & 15] 
                      # imageData[i*4 + 1] = table16[(pixel >> 4) & 15]
                      # imageData[i*4 + 2] = table16[pixel & 15]                     
            # return imageData                 
        # else:
            # return imageBuffer # just copy RGB88 data from file 



        if self.bitDepth != 3: 
            if self.bitDepth == 4:
                format = "b8g8r8a8"
            else:
                if self.bitsGreen == 6:
                    format = "b5g6r5"
                elif self.bitsAlpha == 1:
                    format = "b5g5r5a1"
                else:
                    format = "b4g4r4a4"
                    
            imageData = rapi.imageDecodeRaw(imageBuffer, self.imageWidth, \
                self.imageHeight, format) 
            return imageData                
        else:
            return imageBuffer
               
                 
    def getDXTImage(self, filereader):
        if self.dxtType == 0:     
            imageDataSize = int(self.imageWidth*self.imageHeight/2) 
        else:
            imageDataSize = self.imageWidth*self.imageHeight                     
            
        return filereader.getBuffer()[filereader.tell() : \
            (filereader.tell() + imageDataSize)] 
        
    def readHeader(self):
        self.reader.seek(0, NOESEEK_ABS)
        # rsb version = 0..11
        self.version = self.reader.readUInt()
        
        self.imageWidth = self.reader.readUInt()
        self.imageHeight = self.reader.readUInt()
        
        if self.version == 0: 
            self.containsPalette = self.reader.readUInt() 
            if self.containsPalette == 0:
                self.readBitMask(self.reader)                
           
        if self.version > 7: 
            self.reader.seek(7, NOESEEK_REL)   
            
        if self.version > 0:    
            self.readBitMask(self.reader);
        
        if self.version >= 9: 
            self.reader.seek(4, NOESEEK_REL)         
            self.dxtType = self.reader.readInt() # DXT -1, 1..5
             
        return 0
        
    def getImageData(self, filereader, options):
        if options["type"] == "paletted image":
            return self.getPalettedImage(filereader) 
        elif options["type"] == "DXT":  
            return self.getDXTImage(filereader)
        else:
            return self.getRGBAImage(filereader)        
            
    def read(self, options): 
       return self.getImageData(self.reader, options)

       
def rsbCheckType(data):
    #rsb = RSBImage(NoeBitStream(data))
    return 1
  
  
def rsbLoadRGBA(data, texList): 
    rsb = RSBImage(NoeBitStream(data))
    
    if rsb.readHeader() != 0:
	    return 0    
 
    options = {"display" : "all", "type" : ""} 

    textureType = noesis.NOESISTEX_RGBA32
    
    if options["display"] == "all" and rsb.containsPalette == 1:
         options["type"]  = "paletted image"    
         texList.append(NoeTexture("rsbitmap8tex", rsb.imageWidth, \
             rsb.imageHeight, rsb.read(options), textureType)) 
    
    options["type"] = "RGBA"
    if rsb.dxtType >= 0:
        options["type"] = "DXT"
        if rsb.dxtType == 0: 
            textureType = noesis.NOESISTEX_DXT1
        elif rsb.dxtType == 4:    
            textureType = noesis.NOESISTEX_DXT5
    if rsb.bitDepth == 3:             
      textureType = noesis.NOESISTEX_RGB24 
                    
                 
    texList.append(NoeTexture("rsbitmaptex", rsb.imageWidth, rsb.imageHeight, \
        rsb.read(options), textureType))    
        
    return 1

