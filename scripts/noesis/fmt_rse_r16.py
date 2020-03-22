from inc_noesis import *


def registerNoesisTypes():
    handle = noesis.register( \
        "Red Storm Bitmap (Rainbow six 1/2, Ghost Recon)", ".r16")
    noesis.setHandlerTypeCheck(handle, r16CheckType)
    noesis.setHandlerLoadRGBA(handle, r16LoadRGBA)
    
    return 1

    
class R16Image:
    def __init__(self, reader):
        self.reader = reader
        self.imageWidth = 0
        self.imageHeight = 0    
        self.imageData = None
        
    def readImageData(self, reader):
        size = self.imageWidth * self.imageHeight * 2
        imageBuffer = reader.getBuffer()[29:(29 + size)] 
        format = "b5g5r5a1"                                         
        self.imageData = rapi.imageDecodeRaw(imageBuffer, self.imageWidth, \
                self.imageHeight, format) 
                
        for i in range(size * 2):
            if not(i & 3):            
                self.imageData[i - 1] = 255                  

    def readHeader(self, reader):
        self.imageWidth = reader.readUShort()
        self.imageHeight = reader.readUShort()
             
        return 0
          
    def read(self): 
        self.readHeader(self.reader)
        self.readImageData(self.reader) 

       
def r16CheckType(data):

    return 1
  
  
def r16LoadRGBA(data, texList): 
    r16 = R16Image(NoeBitStream(data))              
    r16.read()
    
    texList.append(NoeTexture("r16bitmaptex", r16.imageWidth, r16.imageHeight, \
        r16.imageData, noesis.NOESISTEX_RGBA32))    
        
    return 1

