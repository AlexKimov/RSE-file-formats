from inc_noesis import *
import os


SECTION_HEADER_SHORT = 0
SECTION_HEADER_LONG = 1 


def registerNoesisTypes():
    handle = noesis.register( \
        "Ghost Recon / The Sum of All Fears (2001) character model", ".chr")
    noesis.setHandlerTypeCheck(handle, grCharacterModelCheckType)
    noesis.setHandlerLoadModel(handle, grCharacterModelLoadModel)
        
    return 1 
    
    
class vector4F:
    def read(self, reader):
        self.x = reader.readFloat()
        self.y = reader.readFloat()
        self.z = reader.readFloat()      
        self.w = reader.readFloat()  
        
    def getStorage(self):
        return (self.x, self.y, self.z, self.w)    
    
    
class vector2F:
    def read(self, reader):
        self.x = reader.readFloat()
        self.y = reader.readFloat()
 
    def getStorage(self):
        return (self.x, self.y)  
        
        
class vector3UI16:
    def read(self, reader):
        self.x = reader.readShort()
        self.y = reader.readShort()
        self.z = reader.readShort()
        
    def getStorage(self):
        return (self.x, self.y, self.z)
        
        
class vector3F:
    def read(self, reader):
        self.x = reader.readFloat()
        self.y = reader.readFloat()
        self.z = reader.readFloat() 
        
    def getStorage(self):
        return (self.x, self.y, self.z) 
    
    
class greColor:
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


class grMaterial: 
    def __init__(self):
        self.opacity = 0
        self.unknown = 0
        self.ambientColor = greColor()
        self.diffuseColor = greColor()
        self.specularColor = greColor()
        self.specularLevel = 0
        self.twoSided = 0
        
    def read(self, reader):
        header = greHeader()
        header.read(reader)    
        self.name = header.name
        self.opacity = reader.readUInt()        
        self.unknown = reader.readUInt()
        self.ambientColor.read(reader)  
        self.diffuseColor.read(reader)        
        self.specularColor.read(reader)                
        self.specularLevel = reader.readFloat() 
        self.twoSided = reader.readUByte()        


class grTexture: 
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
   
   
class greHeader:  
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
            
    
class grModelMesh:
    def __init__(self):  
        self.uvs = []
        self.faceIndexes = []
        self.textureIndexes = []
    
    def read(self, reader):                           
        reader.seek(2, NOESEEK_REL)
        detailTexture = reader.readUByte()  
        self.materialIndex = reader.readUInt()                 
        if reader.readUInt() > 0:
            self.textureIndex = reader.readUInt()        
            if detailTexture > 0:
                reader.seek(4, NOESEEK_REL)
                
        reader.seek(24, NOESEEK_REL)

        self.faceCount = reader.readUInt()          
        reader.seek(16*self.faceCount, NOESEEK_REL)
                
        for i in range(self.faceCount):
            indexes = vector3UI16() 
            indexes.read(reader)              
            self.faceIndexes.append(indexes)
            
        for i in range(self.faceCount):
            indexes = vector3UI16() 
            indexes.read(reader)              
            self.textureIndexes.append(indexes)   

        self.vCount = reader.readUInt()
        self.tCount = reader.readUInt()         
        reader.seek(12*self.vCount, NOESEEK_REL)            
        
        for i in range(self.vCount*self.tCount):
            uv = vector2F() 
            uv.read(reader)              
            self.uvs.append(uv) 

        reader.seek(16*self.vCount, NOESEEK_REL)                      

        
class grModel:    
    def __init__(self):  
        self.vertexes = []
        self.meshes = [] 
        
    def read(self, reader):
        self.vertexCount = reader.readUInt()        
        for i in range(self.vertexCount): 
            vertex = vector3F()
            vertex.read(reader)
            
            self.vertexes.append(vertex)
        
        self.meshCount = reader.readUInt()        
        for i in range(self.meshCount):            
            modelMesh = grModelMesh()
            modelMesh.read(reader)

            self.meshes.append(modelMesh)         
   
   
class grModelBone:
    def __init__(self):
        self.parentName = ""
        self.parentIndex = -1
        self.index = -1
        self.transMatrix = NoeMat43()
        
    def read(self, reader):
        header = greHeader()
        header.read(reader, SECTION_HEADER_SHORT) 
        self.name = header.name       
        self.pos = vector3F()
        self.pos.read(reader)
        self.rot = vector4F()
        self.rot.read(reader)        
        reader.seek(4, NOESEEK_REL)           
        self.childCount = reader.readUInt()         
        
    def getTransMat(self):
        rotQuat = NoeQuat(self.rot.getStorage())
        transMatrix = rotQuat.toMat43().inverse()
        transMatrix[3] = self.pos.getStorage()

        return transMatrix       


class grBoneWeight:
    def __init__(self):
        self.name = ""
        self.weight = 0
        
    def read(self, reader):
        reader.seek(4, NOESEEK_REL)
        self.name = reader.readString()
        self.weight = reader.readFloat()
        
        
class grModelVertexWeight:
    def __init__(self):
        self.bones = []
        
    def read(self, reader):        
        self.vertexIndex = reader.readUInt()     
        boneCount = reader.readUInt()
        for i in range(boneCount):
            boneWeight = grBoneWeight()
            boneWeight.read(reader)
            self.bones.append(boneWeight)
            
    
class GRCharacterModel: 
    def __init__(self, reader):
        self.reader = reader
        self.textures = []
        self.materials = []
        self.skeleton = []
        self.models = []
        self.weights = []
        
    def readFileHeader(self, reader):
        self.version = self.reader.readFloat()
        self.reader.seek(4, NOESEEK_REL)
        if self.reader.readString() != "BeginModel":        
            return 0
        
        return 1    
                
    def readMaterialList(self, reader):
        header = greHeader()
        header.read(self.reader) 
      
        # materials
        self.materialCount = self.reader.readUInt()
        for i in range(self.materialCount):      
            mat = grMaterial()
            mat.read(self.reader)
            
            self.materials.append(mat)
     
        # textures  
        self.textureCount = self.reader.readUInt()        
        for i in range(self.textureCount):
            header = greHeader()
            header.read(self.reader) 
            
            self.reader.seek(1, NOESEEK_REL) # unknown parameter
            
            texture = grTexture()
            texture.read(self.reader)
            
            self.textures.append(texture)                           
            
    def readGeometryList(self, reader):
        header = greHeader()
        header.read(self.reader)      
        
        self.modelCount = self.reader.readUInt()
        for i in range(self.modelCount):
            header = greHeader()
            header.read(self.reader) 
            
            self.reader.seek(2, NOESEEK_REL)  
            
            model = grModel()  
            model.read(reader) 

            self.models.append(model)            
               
        self.reader.seek(4, NOESEEK_REL) # unknown parameter     
       
    def getBoneIndexByName(self, name):
        for bone in self.skeleton:
            if bone.name == name:
                return bone.index            
       
    def readBone(self, reader, parentName = None, parentIndex = -1):      
        skeletonBone = grModelBone()
        skeletonBone.read(reader)
        skeletonBone.parentIndex = parentIndex        
        if parentName != None:
            skeletonBone.parentName = parentName
            skeletonBone.parentIndex = parentIndex      

        skeletonBone.index = len(self.skeleton)
        self.skeleton.append(skeletonBone)
            
        for i in range(skeletonBone.childCount):
            self.readBone(reader, skeletonBone.name, skeletonBone.index)
        
    def readBoneWeights(self, reader):    
        reader.seek(4, NOESEEK_REL) # unknown parameter    
        self.name = reader.readString()
        
        header = greHeader()
        header.read(reader, SECTION_HEADER_SHORT) 
        
        vertexCount = reader.readUInt()
        for i in range(vertexCount):
            vertexWeight = grModelVertexWeight()
            vertexWeight.read(reader)            
        
            self.weights.append(vertexWeight)
            
    def read(self):
        #noesis.logPopup()
        self.readFileHeader(self.reader)   
        self.readMaterialList(self.reader)
        self.readGeometryList(self.reader)
              
        self.reader.seek(4, NOESEEK_REL)
        if self.reader.readString() != "EndModel":        
            return 0      
                        
        self.readBone(self.reader)         
        self.readBoneWeights(self.reader)   
        
        
class grPosKey:
    def __init__(self):
        self.time = 0
        self.pos = vector3F() 
    
    def read(self, reader):
        self.time = reader.readUInt()         
        self.pos.read(reader)
            
        
class grRotKey:
    def __init__(self):
        self.time = 0
        self.rot = vector4F()
        
    def read(self, reader):
        self.time = reader.readUInt()         
        self.rot.read(reader)
                    
        
class grBoneAnimations:
    def __init__(self):
        self.posKeys = []
        self.rotKeys = []
        
    def read(self, reader):
        reader.seek(4, NOESEEK_REL)
        self.name = reader.readString()
        
        self.posKeyCount = reader.readUInt() 
        for i in range(self.posKeyCount):
            key = grPosKey()
            key.read(reader)
            
            self.posKeys.append(key)
            
        self.rotKeyCount = reader.readUInt()            
        for i in range(self.rotKeyCount):
            key = grRotKey()
            key.read(reader)
            
            self.rotKeys.append(key)         
        
        
class grSkeletalAnimations:
    def __init__(self):
        self.animations = []
        
    def readHeader(self, reader):
        self.time = self.reader.readFloat()
        self.frameCount = self.reader.readUInt() 
        self.boneCount = self.reader.readUInt()         
        
    def readBoneAnimations(self, reader):
        for i in range(self.boneCount):
            boneAnimations = grBoneAnimations()
            boneAnimations.read(reader)
            
            self.animations.append(boneAnimations)
 
    def read(self, filename):
        #try:
            with open(filename, "rb") as filereader:
                self.reader = NoeBitStream(filereader.read())
            
                self.filename = filename
            
                self.readHeader(self.reader)
                self.readBoneAnimations(self.reader)
                
        #except:
            #return None        
        
        
def grCharacterModelCheckType(data):

	return 1     
    

def grCharacterModelLoadModel(data, mdlList): 
    grCharacterModel = GRCharacterModel(NoeBitStream(data))
    grCharacterModel.read()
    
    ctx = rapi.rpgCreateContext()
    
    #transMatrix = NoeMat43( ((1, 0, 0), (0, 0, 1), (0, -1, 0), (0, 0, 0)) ) 
    #rapi.rpgSetTransform(transMatrix)      
    
    texturesPath = ""
    # load textures
    if grCharacterModel.materials:
        materials = []
        textures = [] 
        for i in range(grCharacterModel.textureCount):        
            filename = grCharacterModel.textures[i].filename.split(".")[0]            
            textureName = "{}{}.rsb".format(texturesPath, filename)               
            texture = rapi.loadExternalTex(textureName)
            if texture != None:
                textures.append(texture)            
                material = NoeMaterial(grCharacterModel.materials[i].name, textureName)
                material.setFlags(noesis.NMATFLAG_TWOSIDED, 1)
                materials.append(material)
        
        if len(textures) != grCharacterModel.textureCount:
            materials = []
            textures = []  
    
    #noesis.logPopup()
    
    # show meshes
    for model in grCharacterModel.models:
        for msh in model.meshes:  
        
            if materials:
                rapi.rpgSetMaterial(grCharacterModel.materials[msh.materialIndex].name)  
                
            rapi.immBegin(noesis.RPGEO_TRIANGLE)
            for i in range(msh.faceCount):
                textIndexes = msh.textureIndexes[i]
                faceIndexes = msh.faceIndexes[i]
                
                for k in range(3):
                    tIndex = textIndexes.getStorage()[k]
                    uv =  msh.uvs[tIndex]
                    rapi.immUV2(uv.getStorage()) 
                    
                    vIndex = faceIndexes.getStorage()[k]
                    vertex =  model.vertexes[vIndex]           
                    rapi.immVertex3(vertex.getStorage())
                    
                    #for bone in grCharacterModel.weights[vIndex].bones:
                        #index = grCharacterModel.getBoneIndexByName(bone.name)
                        #rapi.immBoneIndex([index])
                        #rapi.immBoneWeight([bone.weight])                    
                    
            rapi.immEnd()              

    mdl = rapi.rpgConstructModelSlim()
    
    # show skeleton
    bones = []
    for bone in grCharacterModel.skeleton:
        boneName = bone.name
        if bone.parentName != "":
            parentMat = grCharacterModel.skeleton[bone.parentIndex].transMatrix
            boneMat = bone.getTransMat()*parentMat
            bone.transMatrix = boneMat
        else:          
            bone.transMatrix = bone.getTransMat()
            boneMat = bone.transMatrix 
   
        bonePName = bone.parentName
        bones.append(NoeBone(bone.index, boneName, boneMat, bonePName, bone.parentIndex))
      
    #noesis.logPopup()  
    # load animations from .bmf file
    boneAnimationsFile = grSkeletalAnimations()
    boneAnimationsFile.read("E:/ridingshotgundeath1.bmf")

    # create animations
    index = 0
    kfBones = []
    for boneAnimations in boneAnimationsFile.animations:
        index = grCharacterModel.getBoneIndexByName(boneAnimations.name)
        keyFramedBone = NoeKeyFramedBone(index)
        
        rkeys = []
        for rotKey in boneAnimations.rotKeys:
            rkeys.append(NoeKeyFramedValue(rotKey.time, \
                NoeQuat(rotKey.rot.getStorage())))
        keyFramedBone.setRotation(rkeys)
        
        pkeys = []
        for posKey in boneAnimations.posKeys:
            pkeys.append(NoeKeyFramedValue(posKey.time, \
                NoeVec3(posKey.pos.getStorage()))) 
                
        keyFramedBone.setTranslation(pkeys)
        
        kfBones.append(keyFramedBone)   
        
    anims = []        
    anim = NoeKeyFramedAnim(boneAnimationsFile.filename, bones, kfBones)
    anims.append(anim)
    
    #print(kfBones[0].)
                
    mdl.setBones(bones)
    mdl.setAnims(anims)
    # set materials
    if materials:    
        mdl.setModelMaterials(NoeModelMaterials(textures, materials)) 
    mdlList.append(mdl)
    
    rapi.setPreviewOption("setAngOfs", "0 -90 0")
	
    return 1        