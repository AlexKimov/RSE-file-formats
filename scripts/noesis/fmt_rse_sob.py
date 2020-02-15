from inc_noesis import *
import os


SECTION_HEADER_SHORT = 0
SECTION_HEADER_LONG = 1
COLOR_RGBA = 3
COLOR_RGB = 4 


def registerNoesisTypes():
    handle = noesis.register( \
        "Rainbow Six (1998) static model", ".sob")
    noesis.setHandlerTypeCheck(handle, rsStaticModelCheckType)
    noesis.setHandlerLoadModel(handle, rsStaticModelLoadModel)
        
    return 1 
    
    
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
    
    
class GREColor:
    def __init__(self, type=COLOR_RGBA, isNormalized=True):
        self.isNormalized = isNormalized 
        self.type = type
        self.Red = 0
        self.Green = 0
        self.Blue = 0
        self.Alpha = 0  
        
    def read(self, reader):
        if self.isNormalized:
            self.Red = reader.readFloat() 
            self.Green = reader.readFloat() 
            self.Blue = reader.readFloat() 
            if type == COLOR_RGBA:
                self.Alpha = reader.readFloat()
        else:
            self.Red = reader.readUInt() 
            self.Green = reader.readUInt() 
            self.Blue = reader.readUInt() 
            if type == COLOR_RGBA:
                self.Alpha = reader.readUInt()                         


class RSMaterial: 
    def __init__(self):
        self.opacity = 0
        self.unknown = 0
        self.ambientColor = GREColor(COLOR_RGB, False)
        self.diffuseColor = GREColor(COLOR_RGB, False)
        self.specularColor = GREColor(COLOR_RGB, False)
        self.specularLevel = 0
        self.twoSided = 0
        self.filename = ""
        
    def read(self, reader):
        header = GREHeader()
        header.read(reader)    
        
        reader.seek(4, NOESEEK_REL)
        self.filename = reader.readString()
        
        reader.seek(4, NOESEEK_REL) #
        
        self.opacity = reader.readFloat()        
        self.unknown = reader.readFloat()
        self.ambientColor.read(reader)  
        self.diffuseColor.read(reader)        
        self.specularColor.read(reader)                
        self.specularLevel = reader.readFloat() 
        self.twoSided = reader.readUByte()
                 
   
   
class GREHeader:  
    def __init__(self):
        self.size = 0          
        self.id = 0
        self.version = -1
        self.name = ""
        
    def read(self, reader, type = SECTION_HEADER_LONG):
        if type == SECTION_HEADER_LONG:   
            self.size = reader.readUInt() 
        self.id = reader.readUInt()
        reader.seek(4, NOESEEK_REL)
        str = reader.readString()
        if str == "Version":
            self.version = reader.readUInt()
            reader.seek(4, NOESEEK_REL)
            self.name = reader.readString()
        else:
            self.name = str        
            
    
class RSObjectMesh:
    def __init__(self):  
        self.uvs = []
        self.faceIndexes = []
        self.textureIndexes = []
    
    
class VertexData:
    def __init__(self):  
        self.normal = vector3F()  
        self.uv = vector2F()
        self.color = GREColor(COLOR_RGB, False) 
    
    
class FaceData:
    def __init__(self):  
        self.vertIndexes = vector3UI()
        self.vertDataIndexes = vector3UI()
        self.normal = vector3F()
        self.materialIndex = 0
        
        
class RSObject:    
    def __init__(self):  
        self.vertexes = []
        self.vertexData = []
        self.faceData = [] 
        
    def read(self, reader, isExtended=False):
        if isExtended:
            reader.seek(8, NOESEEK_REL) #unknown  
    
        self.vertexCount = reader.readUInt()        
        for i in range(self.vertexCount): 
            vertex = vector3F()
            vertex.read(reader)
            
            self.vertexes.append(vertex)

        # vertex data
        count = reader.readUInt() 
        
        for i in range(count):
            vertData = VertexData()
            
            vertData.normal.read(reader)          
            vertData.uv.read(reader)
            reader.seek(4, NOESEEK_REL) #unknown          
            vertData.color.read(reader)
            
            self.vertexData.append(vertData)
     
        # face data
        count = reader.readUInt()          
                
        for i in range(count):
            faceData = FaceData()
            
            faceData.vertIndexes.read(reader)   
            faceData.vertDataIndexes.read(reader)         
            faceData.normal.read(reader) 
            reader.seek(4, NOESEEK_REL) #unknown  
            faceData.materialIndex = reader.readInt()
             
            self.faceData.append(faceData)                    
          
        # meshes
        count = reader.readUInt()          
                
        for i in range(count):
            header = GREHeader()
            header.read(reader, SECTION_HEADER_SHORT)

            count = reader.readUInt()
            for i in range(count):
                vertIndex = reader.readUInt()
                
            count = reader.readUInt()               
            for i in range(count):
                faceIndex = reader.readUInt()
                
            reader.seek(4, NOESEEK_REL) #unknown

            reader.seek(4, NOESEEK_REL) #unknown
            reader.readString()
            
            reader.readUInt()             
        
        
class RSStaticModel: 
    def __init__(self, reader):
        self.reader = reader
        self.textures = []
        self.materials = []
        self.objects = []
        
    def readFileHeader(self, reader):
        self.reader.seek(4, NOESEEK_REL)
        if self.reader.readString() != "BeginModel":        
            return 0
        
        return 1    
                
    def readMaterialList(self, reader):
        header = GREHeader()
        header.read(self.reader) 
      
        # materials
        self.materialCount = self.reader.readUInt()
        for i in range(self.materialCount):      
            mat = RSMaterial()
            mat.read(self.reader)
            
            self.materials.append(mat)
                         
            
    def readGeometryList(self, reader):
        header = GREHeader()
        header.read(self.reader)      
        
        self.modelCount = self.reader.readUInt()
        for i in range(self.modelCount):
            header = GREHeader()
            header.read(self.reader) 
            
            staticObject = RSObject()  
            staticObject.read(reader, header.version != -1)          

            self.objects.append(staticObject)            
       
    def read(self):
        self.readFileHeader(self.reader)   
        self.readMaterialList(self.reader)   
        self.readGeometryList(self.reader)

        self.reader.seek(4, NOESEEK_REL)
        if self.reader.readString() != "EndModel":        
            return 0                           

        
def rsStaticModelCheckType(data):

	return 1     
    

def rsStaticModelLoadModel(data, mdlList): 
    rsStatModel = RSStaticModel(NoeBitStream(data))
    noesis.logPopup()

    if rsStatModel.read() == 0:
        return 1
     
    ctx = rapi.rpgCreateContext()

    #transMatrix = NoeMat43( ((1, 0, 0), (0, 0, 1), (0, -1, 0), (0, 0, 0)) ) 
    #rapi.rpgSetTransform(transMatrix)      
    
    #texturesPath = "C:/GOG Games/Tom Clancy's Rainbow Six/data/texture/"
    
    # load textures
    if rsStatModel.materials: 
        materials = []
        textures = [] 
        
        for mat in rsStatModel.materials: 
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
    for object in rsStatModel.objects:
        for face in object.faceData:  
            if materials:
                rapi.rpgSetMaterial(rsStatModel.materials[face.materialIndex].filename.split(".")[0])  
                
            rapi.immBegin(noesis.RPGEO_TRIANGLE) 
            
            for i in range(3):    
                index = face.vertDataIndexes.getStorage()[i]             
                rapi.immUV2(object.vertexData[index].uv.getStorage()) 
                rapi.immNormal3(object.vertexData[index].normal.getStorage())
                
                index = face.vertIndexes.getStorage()[i]            
                rapi.immVertex3(object.vertexes[index].getStorage())
                
                
            rapi.immEnd()              

    mdl = rapi.rpgConstructModelSlim()

    # set materials
    if materials:    
        mdl.setModelMaterials(NoeModelMaterials(textures, materials)) 
        
    mdlList.append(mdl)
    
    #rapi.setPreviewOption("setAngOfs", "0 -90 0")
	
    return 1        