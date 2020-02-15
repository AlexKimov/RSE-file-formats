from inc_noesis import *
import os


def registerNoesisTypes():
    handle = noesis.register("Rainbow Six (1998) character model", ".crp")
    noesis.setHandlerTypeCheck(handle, rsCharacterModelCheckType)
    noesis.setHandlerLoadModel(handle, rsCharacterModelLoadModel)
        
    return 1 


EXTENDED = 1
    
    
class vector2F:
    def __init__(self):
        self.x = 0
        self.y = 0
        
    def read(self, reader):
        self.x = reader.readFloat()
        self.y = reader.readFloat()
 
    def getStorage(self):
        return (self.x, self.y)  
        
        
class vector3UI16:
    def __init__(self):
        self.x = 0
        self.y = 0
        self.z = 0
        
    def read(self, reader):
        self.x = reader.readShort()
        self.y = reader.readShort()
        self.z = reader.readShort()
        
    def getStorage(self):
        return (self.x, self.y, self.z)
        
        
class vector3F:
    def __init__(self):
        self.x = 0
        self.y = 0
        self.z = 0
    
    def read(self, reader):
        self.x = reader.readFloat()
        self.y = reader.readFloat()
        self.z = reader.readFloat() 
        
    def getStorage(self):
        return (self.x, self.y, self.z) 
    
    
class vector3UI:
    def __init__(self):
        self.x = 0
        self.y = 0
        self.z = 0
    
    def read(self, reader):
        self.x = reader.readUInt()
        self.y = reader.readUInt()
        self.z = reader.readUInt() 
        
    def getStorage(self):
        return (self.x, self.y, self.z)     
    
    
class CRPColor:
    def __init__(self, type=0):
        self.type = type
        self.red = 0
        self.green = 0
        self.blue = 0
        self.alpha = 0  
        
    def read(self, reader):
        if self.type == EXTENDED:
            self.blue =  reader.readUInt()
            self.green = reader.readUInt()
            self.red =   reader.readUInt()                      
            self.alpha =   reader.readUInt()     
        else:
            color = reader.readUInt() 
            self.blue =  color & 255
            self.green = (color >> 8) & 255
            self.red =   (color >> 16) & 255                       
            self.alpha =   (color >> 24) & 255  


class RSCharacterMaterial: 
    def __init__(self):
        self.opacity = 0
        self.ambientColor = CRPColor()
        self.diffuseColor = CRPColor()
        self.specularColor = CRPColor()
        self.specularLevel = 0
        self.twoSided = 0
        self.filename = ""
        
    def read(self, reader):   
        reader.seek(4, NOESEEK_REL)
        self.filename = reader.readString()
        
        self.ambientColor.read(reader)  
        self.diffuseColor.read(reader)         
        
        reader.seek(4, NOESEEK_REL) #        
        self.opacity = reader.readUInt() 
        self.twoSided = reader.readByte()      


class Vertex:
    def __init__(self): 
        self.coordinates = vector3F()
        self.index = 0
  
  
class VertexData:
    def __init__(self):  
        self.uv = vector2F()  
        self.normal = vector3F() 
        self.color = CRPColor(EXTENDED)
    
    
class FaceData:
    def __init__(self):  
        self.vertIndexes = vector3UI()
        self.textIndexes = vector3UI()
        self.materialIndex = 0
        
        
class RSCharacterModel: 
    def __init__(self, reader):
        self.reader = reader
        self.vertexes = []
        self.vertexes2 = []
        self.vertexIndexes = []
        self.materials = []
        self.faceData = []
        self.vertexData = []
                
    def readVertexes(self, reader):
        indx = []
    
        for index in range(18):         
            count = reader.readUInt()

            startIndex = len(self.vertexes)
             
            for i in range(count): 
                vertex = Vertex()
                self.vertexes.append(vertex) 
            
            for i in range(startIndex, startIndex + count):
                self.vertexes[i].index = reader.readUInt() 
    
            for i in range(startIndex, startIndex + count):              
                self.vertexes[i].coordinates.read(reader)
                          
    def readMaterials(self, reader):        
        reader.seek(8, NOESEEK_REL)
        reader.readString()
        reader.seek(24, NOESEEK_REL)
        
        # materials
        count = reader.readUInt()

        for i in range(count):       
            mat = RSCharacterMaterial()
            mat.read(reader)
            
            self.materials.append(mat)       

    def readFaceData(self, reader):        
        count = self.reader.readUInt()
        for i in range(count):
            face = FaceData()    
            
            face.vertIndexes.read(reader)
            face.textIndexes.read(reader)
            face.materialIndex = reader.readUInt()
            reader.seek(4, NOESEEK_REL)
            
            self.faceData.append(face)           

    def readVertexData(self, reader):     
        count = self.reader.readUInt()
        for i in range(count):         
            vertData = VertexData()    
            
            vertData.uv.read(reader)
            vertData.normal.read(reader)
            vertData.color.read(reader)
            
            self.vertexData.append(vertData)           
       
    def readSomeInfo(self, reader):     
        count = self.reader.readUInt()
        
        for i in range(count):
            a = vector3F()
            a.read(reader)            
            self.vertexes2.append(a)  
            
        #reader.seek(count * 12, NOESEEK_REL)       
       
    def read(self):
        noesis.logPopup()
        self.readVertexes(self.reader)   
        self.readMaterials(self.reader)       
        self.readFaceData(self.reader) 
        self.readSomeInfo(self.reader)
        self.readVertexData(self.reader) 

        
def rsCharacterModelCheckType(data):

	return 1     
    

def rsCharacterModelLoadModel(data, mdlList): 
    rsCharacterModel = RSCharacterModel(NoeBitStream(data))

    if rsCharacterModel.read() == 0:
        return 1
     
    ctx = rapi.rpgCreateContext()

    #transMatrix = NoeMat43( ((1, 0, 0), (0, 0, 1), (0, -1, 0), (0, 0, 0)) ) 
    #rapi.rpgSetTransform(transMatrix)      
    
    texturesPath = "C:/GOG Games/Tom Clancy's Rainbow Six/data/texture/"
    
    # load textures
    if rsCharacterModel.materials: 
        materials = []
        textures = [] 
        
        for mat in rsCharacterModel.materials: 
            filename = mat.filename.split(".")[0]            
            textureName = "{}{}.rsb".format(texturesPath, filename) 
            
            texture = rapi.loadExternalTex(textureName)        
            if texture == None:
                texture = NoeTexture(textureName, 0, 0, bytearray())
                        
            textures.append(texture)    
            
            material = NoeMaterial(filename, textureName)
            material.setFlags(noesis.NMATFLAG_TWOSIDED, 1)
            materials.append(material)

    # show meshes
    for face in rsCharacterModel.faceData:   
        if materials:
            rapi.rpgSetMaterial(rsCharacterModel.materials[face.materialIndex].filename.split(".")[0])  
            
        rapi.immBegin(noesis.RPGEO_TRIANGLE)   
        
        for i in range(3):
            index = face.textIndexes.getStorage()[i]          
            rapi.immUV2(rsCharacterModel.vertexData[index].uv.getStorage()) 
            rapi.immNormal3(rsCharacterModel.vertexData[index].normal.getStorage()) 
            
            index = face.vertIndexes.getStorage()[i]
            
            rapi.immVertex3(rsCharacterModel.vertexes2[index].getStorage())
            
            # for vert in rsCharacterModel.vertexes:
                # if index == vert.index:
                     # rapi.immVertex3(vert.coordinates.getStorage())
                   
        rapi.immEnd()              

    mdl = rapi.rpgConstructModelSlim()

    # set materials
    if materials:    
        mdl.setModelMaterials(NoeModelMaterials(textures, materials)) 
        
    mdlList.append(mdl)
    
    #rapi.setPreviewOption("setAngOfs", "0 -90 0")
	
    return 1        