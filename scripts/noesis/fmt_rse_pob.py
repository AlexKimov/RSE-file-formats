from inc_noesis import *
import os
import noewin
import noewinext

SECTION_HEADER_SHORT = 0
SECTION_HEADER_LONG = 1 


def registerNoesisTypes():
    handle = noesis.register( \
        "Ghost Recon / The Sum of All Fears (2001) model", ".pob")
    
    noesis.setHandlerTypeCheck(handle, grModelCheckType)
    noesis.setHandlerLoadModel(handle, grModelLoadModel)
        
    return 1 
    
    
class Vector4F:
    def read(self, reader):
        self.x = reader.readFloat()
        self.y = reader.readFloat()
        self.z = reader.readFloat()      
        self.w = reader.readFloat()  
        
    def getStorage(self):
        return (self.x, self.y, self.z, self.w)    
    
    
class Vector2F:
    def read(self, reader):
        self.x = reader.readFloat()
        self.y = reader.readFloat()
 
    def getStorage(self):
        return (self.x, self.y)  
        
        
class Vector3UI16:
    def read(self, reader):
        self.x = reader.readShort()
        self.y = reader.readShort()
        self.z = reader.readShort()
        
    def getStorage(self):
        return (self.x, self.y, self.z)
        
        
class Vector3F:
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
       
       
class Matrix4x3:
    def __init__(self):
        self.x = Vector3F() 
        self.y = Vector3F() 
        self.z = Vector3F() 
        self.pos = Vector3F()        
    
    def read(self, reader):
        self.x.read(reader)
        self.y.read(reader)
        self.z.read(reader) 
        self.pos.read(reader)  
        
    def getStorage(self):
        return (self.x.getStorage(), self.y.getStorage(), self.z.getStorage(), self.pos.getStorage())
    
    
class GREColor:
    def __init__(self):
        self.Red = 0
        self.Green = 0
        self.Blue = 0
        self.Alpha = 0  
        
    def read(self, reader):
        self.Red = reader.readFloat() 
        self.Green = reader.readFloat() 
        self.Blue = reader.readFloat() 
        self.Alpha = reader.readFloat()           


class GRMaterial: 
    def __init__(self):
        self.opacity = 0
        self.unknown = 0
        self.ambientColor = GREColor()
        self.diffuseColor = GREColor()
        self.specularColor = GREColor()
        self.specularLevel = 0
        self.twoSided = 0
        
    def read(self, reader):
        header = GREHeader()
        header.read(reader)    
        self.name = header.name
        self.opacity = reader.readUInt()        
        self.unknown = reader.readUInt()
        self.ambientColor.read(reader)  
        self.diffuseColor.read(reader)        
        self.specularColor.read(reader)                
        self.specularLevel = reader.readFloat() 
        self.twoSided = reader.readUByte()        
        

class GRTexture: 
    def __init__(self):
        self.filename = ""
        self.transparencyType = 0
        self.isTiled = 0
        self.selfIllumination = 0   
        
    def read(self, reader): 
        reader.seek(4, NOESEEK_REL)    
        self.filename = reader.readString()
        self.transparencyType = reader.readUInt()
        self.isTiled = reader.readUInt()
        self.selfIllumination = reader.readFloat()               
   
   
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
            
    
class GRMesh:
    def __init__(self):  
        self.uvs = []
        self.faceIndexes = []
        self.textureIndexes = []
    
    def read(self, reader):                           
        reader.seek(2, NOESEEK_REL)
        detailTexture = reader.readUByte()  
        self.materialIndex = reader.readInt() 
      
        if reader.readUInt() > 0:
            self.textureIndex = reader.readUInt()        
            if detailTexture > 0:
                reader.seek(4, NOESEEK_REL)
                
        reader.seek(24, NOESEEK_REL)

        self.faceCount = reader.readUInt()          
        reader.seek(16*self.faceCount, NOESEEK_REL)
                
        for i in range(self.faceCount):
            indexes = Vector3UI16() 
            indexes.read(reader)              
            self.faceIndexes.append(indexes)
            
        for i in range(self.faceCount):
            indexes = Vector3UI16() 
            indexes.read(reader)              
            self.textureIndexes.append(indexes)   

        self.vCount = reader.readUInt()
        self.tCount = reader.readUInt()         
        reader.seek(12*self.vCount, NOESEEK_REL)            
        
        for i in range(self.vCount*self.tCount):
            uv = Vector2F() 
            uv.read(reader)              
            self.uvs.append(uv) 

        reader.seek(16*self.vCount, NOESEEK_REL) 
                


class GRTaggedPoint():
    def __init__(self):
        self.name = ""
        self.matrix = Matrix4x3()    
    
    def read (self, reader):
        reader.seek(4, NOESEEK_REL)
        self.name = reader.readString()
        self.matrix.read(reader)     
 

class GRProperties(): 
    def __init__(self, version):
        self.name = ""
        self.properties = -1
        if version > 7:        
            self.isSurface = True
        
    def read (self, reader):
        reader.seek(4, NOESEEK_REL)
        self.name = reader.readString()
        self.properties = reader.readInt()
        if self.isSurface:
           self.surfaceProperty = reader.readInt()
        
        
class GRObject:    
    def __init__(self, version=0, name=""):
        self.version = version    
        self.vertexes = []
        self.meshes = []
        self.taggedPoints = []         
        self.name = name
        
    def read(self, reader):
        self.vertexCount = reader.readUInt()        
        for i in range(self.vertexCount): 
            vertex = Vector3F()
            vertex.read(reader)
            
            self.vertexes.append(vertex)
        
        self.meshCount = reader.readUInt()        
        for i in range(self.meshCount):            
            modelMesh = GRMesh()
            modelMesh.read(reader)

            self.meshes.append(modelMesh) 
        count = reader.readUInt()        
        for i in range(count):            
            taggedPoint = GRTaggedPoint()
            taggedPoint.read(reader)

            self.taggedPoints.append(taggedPoint) 
        
        # skip everything else            
        count = reader.readUInt()
        reader.seek(count * 12, NOESEEK_REL)        
        count = reader.readUInt()
        reader.seek(count * 16, NOESEEK_REL)  
               
        reader.seek(4, NOESEEK_REL)
           
        pcount = reader.readUInt() 
        for i in range(pcount):            
            point = GRProperties(self.version)
            point.read(reader)  
             
        count = reader.readUInt()
        for k in range(count):
            pcount = reader.readUInt() 
            for i in range(pcount):            
                point = GRProperties(self.version)
                point.read(reader)    

            ncount = reader.readUInt()
            reader.seek(ncount * 8, NOESEEK_REL)  
  
  
class GRObjectListNode:
    def __init__(self):
        self.childNodes = []
        self.name = ""
        self.matrix = Matrix4x3()
        self.id = -1
        
    
class GRModel: 
    def __init__(self, reader):
        self.reader = reader
        self.version = -1
        self.textures = []
        self.materials = []
        self.objects = []
        self.helperPoints = []
        self.nodes = None
        
    def readFileHeader(self, reader):
        self.reader.seek(4, NOESEEK_REL)
        if self.reader.readString() != "BeginPOB":        
            return 0
            
        self.version = self.reader.readUInt()
        self.reader.seek(4, NOESEEK_REL) # changed date
        
        self.reader.seek(4, NOESEEK_REL)
        if self.reader.readString() != "BeginModel":        
            return 0
        
        return 1    
      
    def getObjectByName(self, name):
        for object in self.objects:
            if object.name == name:
                return object
                
        return None    
        
    def getMaterialNameByIndex(self, index):
        if index >= 0:
            return self.materials[index].name      
      
    def readMaterialList(self, reader):
        header = GREHeader()
        header.read(self.reader) 
      
        # materials
        self.materialCount = self.reader.readUInt()
        for i in range(self.materialCount):      
            mat = GRMaterial()
            mat.read(self.reader)
            
            self.materials.append(mat)
     
        # textures  
        self.textureCount = self.reader.readUInt()        
        for i in range(self.textureCount):
            header = GREHeader()
            header.read(self.reader) 
            
            self.reader.seek(1, NOESEEK_REL) # unknown parameter
            
            texture = GRTexture()
            texture.read(self.reader)
            
            self.textures.append(texture)                           
            
    def readGeometryList(self, reader):
        header = GREHeader()
        header.read(self.reader)     
        
        count = self.reader.readUInt()
        for i in range(count):
            header = GREHeader()
            header.read(self.reader) 
            header2 = GREHeader()
            header2.read(self.reader)
            
            self.reader.seek(2, NOESEEK_REL)  
            
            model = GRObject(header2.version, header2.name)  
            model.read(reader) 

            self.objects.append(model)         
            
    def readObjectNode(self, reader):
        node = GRObjectListNode()
        
        header = GREHeader()
        header.read(self.reader)
         
        node.name = header.name   
        if header.size == 1:
            self.reader.seek(1, NOESEEK_REL)
        else:        
            if header.id != 51:
                length = reader.readUInt()
                reader.readBytes(length)
            else:
                self.reader.seek(1, NOESEEK_REL) 
            
            node.matrix.read(reader) 
            
            if header.id == 48:
                reader.seek(4, NOESEEK_REL)
                
            if header.id == 50:
                self.reader.seek(31, NOESEEK_REL)
                count = reader.readUInt()
                for i in range(count):
                    type = reader.readUInt()
                    reader.seek(24, NOESEEK_REL)
                    if type != 3:
                        reader.seek(12, NOESEEK_REL) 
                        
                count = reader.readUInt()
                for i in range(count):
                    type = reader.readUInt()
                    if type == 4:
                        reader.seek(66, NOESEEK_REL)                         
               
            childCount = reader.readUInt()              
            for i in range(childCount):
                childNode = self.readObjectNode(reader)

                node.childNodes.append(childNode)
                
        return node                
        
    def readObjectList(self, reader):
        header = GREHeader()
        header.read(self.reader)

        reader.seek(4, NOESEEK_REL)
        header = GREHeader()
        header.read(self.reader)
        
        self.nodes = self.readObjectNode(reader)
                
    def read(self):
        if self.readFileHeader(self.reader) == 0:
            return 0

        noesis.logPopup() 
        self.readMaterialList(self.reader)
        self.readGeometryList(self.reader)
        
        self.reader.seek(4, NOESEEK_REL)
        if self.reader.readString() != "EndModel":   
            return 0  
            
        self.readObjectList(self.reader)
     
        
def grModelCheckType(data):

	return 1     
    

class ModelMeshes:
    def __init__(self, model):
       self.model = model 
    
    def build(self):
        self.processNode(self.model.nodes)
    
    def processNode(self, node, parentMat=None): 
        matrix = NoeMat43(node.matrix.getStorage())
        
        if parentMat is not None:    
            matrix = matrix * parentMat  
            
        self.addMesh(node.name, matrix)
        
        for childNode in node.childNodes:
            self.processNode(childNode, matrix)   
            
    def addMesh(self, meshName, matrix):
        rapi.rpgSetTransform(matrix) 
        model = self.model.getObjectByName(meshName)
     
        if model is not None:
            for msh in model.meshes:
                if msh.materialIndex >= 0:
                    materialName = self.model.getMaterialNameByIndex(msh.materialIndex)  
                    print(materialName)                    
                    rapi.rpgSetMaterial(materialName)  
    
                rapi.immBegin(noesis.RPGEO_TRIANGLE)

                for i in range(msh.faceCount):
                    if msh.materialIndex >= 0:   
                        textIndexes = msh.textureIndexes[i]
                    faceIndexes = msh.faceIndexes[i]
    
                    for k in range(3):
                        if msh.materialIndex >= 0: 
                            tIndex = textIndexes.getStorage()[k]
                            uv =  msh.uvs[tIndex]
                            rapi.immUV2(uv.getStorage()) 
        
                        vIndex = faceIndexes.getStorage()[k]                    
        
                        vertex =  model.vertexes[vIndex]           
                        rapi.immVertex3(vertex.getStorage())
                            
                rapi.immEnd() 
           
    
def grModelLoadModel(data, mdlList):
    grModel = GRModel(NoeBitStream(data))
    grModel.read()
    
    ctx = rapi.rpgCreateContext()    
    
    texturesPath = "F:/SteamLibrary/steamapps/common/Ghost Recon/Mods/Origmiss/Textures"
    # load textures
    if grModel.materials:
        materials = []
        textures = [] 
        for i in range(grModel.textureCount):            
            textureName = "{}/{}.rsb".format(texturesPath, grModel.textures[i].filename.split(".")[0])                
            texture = rapi.loadExternalTex(textureName)

            if texture != None:
                textures.append(texture)            
                material = NoeMaterial(grModel.materials[i].name, textureName)
                material.setFlags(noesis.NMATFLAG_TWOSIDED, 1)
                materials.append(material) 

    # show meshes
    modMeshes = ModelMeshes(grModel)
    modMeshes.build()
            
    mdl = rapi.rpgConstructModelSlim()
    
    # set materials
    if materials:    
        mdl.setModelMaterials(NoeModelMaterials(textures, materials)) 
    mdlList.append(mdl)
    
    rapi.setPreviewOption("setAngOfs", "0 -90 0")
	
    return 1        