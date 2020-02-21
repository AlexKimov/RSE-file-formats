from inc_noesis import *
import os
import noewin
import noewinext


SECTION_HEADER_SHORT = 0
SECTION_HEADER_LONG = 1 


def registerNoesisTypes():
    handle = noesis.register( \
        "Ghost Recon / The Sum of All Fears (2001) character model", ".chr")
        
    noesis.addOption(handle, "-nogui", "disables UI", 0)    
    noesis.addOption(handle, "-animation", "bmf file", noesis.OPTFLAG_WANTARG)
    
    noesis.setHandlerTypeCheck(handle, grCharacterModelCheckType)
    noesis.setHandlerLoadModel(handle, grCharacterModelLoadModel)
        
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
    def read(self, reader):
        self.x = reader.readFloat()
        self.y = reader.readFloat()
        self.z = reader.readFloat() 
        
    def getStorage(self):
        return (self.x, self.y, self.z) 
    
    
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
            
    
class GRModelMesh:
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

        
class GRModel:    
    def __init__(self):  
        self.vertexes = []
        self.meshes = [] 
        
    def read(self, reader):
        self.vertexCount = reader.readUInt()        
        for i in range(self.vertexCount): 
            vertex = Vector3F()
            vertex.read(reader)
            
            self.vertexes.append(vertex)
        
        self.meshCount = reader.readUInt()        
        for i in range(self.meshCount):            
            modelMesh = GRModelMesh()
            modelMesh.read(reader)

            self.meshes.append(modelMesh)         
   
   
class GRModelBone:
    def __init__(self):
        self.parentName = ""
        self.parentIndex = -1
        self.index = -1
        self.transMatrix = NoeMat43()
        
    def read(self, reader):
        header = GREHeader()
        header.read(reader, SECTION_HEADER_SHORT) 
        self.name = header.name       
        self.pos = Vector3F()
        self.pos.read(reader)
        self.rot = Vector4F()
        self.rot.read(reader)        
        reader.seek(4, NOESEEK_REL)           
        self.childCount = reader.readUInt()         
        
    def getTransMat(self):
        rotQuat = NoeQuat(self.rot.getStorage())
        transMatrix = rotQuat.toMat43().inverse()
        transMatrix[3] = self.pos.getStorage()

        return transMatrix       


class GRBoneWeight:
    def __init__(self):
        self.name = ""
        self.weight = 0
        
    def read(self, reader):
        reader.seek(4, NOESEEK_REL)
        self.name = reader.readString()
        self.weight = reader.readFloat()
        
        
class GRModelVertexWeight:
    def __init__(self):
        self.bones = []
        
    def read(self, reader):        
        self.vertexIndex = reader.readUInt()     
        boneCount = reader.readUInt()
        for i in range(boneCount):
            boneWeight = GRBoneWeight()
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
        
        self.modelCount = self.reader.readUInt()
        for i in range(self.modelCount):
            header = GREHeader()
            header.read(self.reader) 
            
            self.reader.seek(2, NOESEEK_REL)  
            
            model = GRModel()  
            model.read(reader) 

            self.models.append(model)            
               
        self.reader.seek(4, NOESEEK_REL) # unknown parameter     
       
    def getBoneIndexByName(self, name):
        for bone in self.skeleton:
            if bone.name == name:
                return bone.index            
       
    def readBone(self, reader, parentName = None, parentIndex = -1):      
        skeletonBone = GRModelBone()
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
        
        header = GREHeader()
        header.read(reader, SECTION_HEADER_SHORT) 
        
        vertexCount = reader.readUInt()
        for i in range(vertexCount):
            vertexWeight = GRModelVertexWeight()
            vertexWeight.read(reader)            
        
            self.weights.append(vertexWeight)
            
    def read(self):
        if self.readFileHeader(self.reader) == 0:        
            return 0 
            
        self.readMaterialList(self.reader)
        self.readGeometryList(self.reader)
              
        self.reader.seek(4, NOESEEK_REL)
        if self.reader.readString() != "EndModel":        
            return 0      
                        
        self.readBone(self.reader)         
        self.readBoneWeights(self.reader)   
        
        
class GRPosKey:
    def __init__(self):
        self.time = 0
        self.pos = Vector3F() 
    
    def read(self, reader):
        self.time = reader.readUInt()         
        self.pos.read(reader)
            
        
class GRRotKey:
    def __init__(self):
        self.time = 0
        self.rot = Vector4F()
        
    def read(self, reader):
        self.time = reader.readUInt()         
        self.rot.read(reader)
                    
        
class GRBoneAnimations:
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
        
        
class GRSkeletalAnimations:
    def __init__(self):
        self.animations = []
        self.filename = ""
        
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
     


class GRCharacterViewSettingsDialogWindow:
    def __init__(self):
        self.options = {"Filename": ""}
        self.isCanceled = True
        self.animationListBox = None
        self.bmfPathEditBox = None
        self.bmfDir = ""

    def buttonGetAnimationListOnClick(self, noeWnd, controlId, wParam, lParam):
        dialog = noewinext.NoeUserOpenFolderDialog("Choose folder with animation files")
        self.bmfDir = dialog.getOpenFolderName() 

        if self.bmfDir != None:
            self.bmfPathEditBox.setText(self.bmfDir)

            for file in os.listdir(self.bmfDir):
                if file.endswith(".bmf"):
                    self.animationListBox.addString(file)
                     
        return True

    def buttonLoadOnClick(self, noeWnd, controlId, wParam, lParam):    
        filename = self.animationListBox.getStringForIndex(self.animationListBox.getSelectionIndex())
    
        if filename != None:
            self.options["Filename"] = os.path.join(self.bmfDir, filename) 
            
        self.isCanceled = False
        self.noeWnd.closeWindow()   

        return True

    def buttonCancelOnClick(self, noeWnd, controlId, wParam, lParam):
        self.isCanceled = True
        self.noeWnd.closeWindow()

        return True

    def create(self):
        self.noeWnd = noewin.NoeUserWindow("Load Ghost Recon character model", "openModelWindowClass", 385, 230)
        noeWindowRect = noewin.getNoesisWindowRect()

        if noeWindowRect:
            windowMargin = 100
            self.noeWnd.x = noeWindowRect[0] + windowMargin
            self.noeWnd.y = noeWindowRect[1] + windowMargin

        if self.noeWnd.createWindow():
            self.noeWnd.setFont("Arial", 12)

            self.noeWnd.createStatic("Path to .bmf files", 5, 5, 110, 20)
            # choose path
            index = self.noeWnd.createEditBox(5, 28, 275, 20, "", None, False, False)
            self.bmfPathEditBox = self.noeWnd.getControlByIndex(index)

            self.noeWnd.createStatic("Animation:", 5, 57, 80, 20)
            index = self.noeWnd.createListBox(5, 75, 275, 140)
            self.animationListBox = self.noeWnd.getControlByIndex(index)

            self.noeWnd.createButton("Open", 290, 27, 80, 21, self.buttonGetAnimationListOnClick)
            
            self.noeWnd.createButton("Load", 290, 135, 80, 30, self.buttonLoadOnClick)
            self.noeWnd.createButton("Cancel", 290, 170, 80, 30, self.buttonCancelOnClick)

            self.noeWnd.doModal()
            
        
def grCharacterModelCheckType(data):
    reader = NoeBitStream(data)
    
    reader.seek(8, NOESEEK_REL)
    if reader.readString() != "BeginModel":        
        return 0      
            
    return 1     
    

def grCharacterModelLoadModel(data, mdlList):
    dialogWindow = GRCharacterViewSettingsDialogWindow()
    
    if noesis.optWasInvoked("-animation"):
        animFilename = noesis.optGetArg("-animation")
    
    if not noesis.optWasInvoked("-nogui"): 
        dialogWindow.create()
    
        if dialogWindow.isCanceled:
            return 1

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
                    
                    for bone in grCharacterModel.weights[vIndex].bones:
                        index = grCharacterModel.getBoneIndexByName(bone.name)
                        rapi.immBoneIndex([index])
                        rapi.immBoneWeight([bone.weight])                      
                    
                    vertex =  model.vertexes[vIndex]           
                    rapi.immVertex3(vertex.getStorage())
                    
                  
                    
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
       
    # load animations from .bmf file
    if dialogWindow.options["Filename"]:
        boneAnimationsFile = grSkeletalAnimations()
        boneAnimationsFile.read(dialogWindow.options["Filename"])
    
        # create animations
        index = 0
        kfBones = []
    
        index = 0
        for boneAnimations in boneAnimationsFile.animations:
            keyFramedBone = NoeKeyFramedBone(index)
        
            rkeys = []
            for rotKey in boneAnimations.rotKeys:
                rkeys.append(NoeKeyFramedValue(rotKey.time, \
                    NoeQuat(rotKey.rot.getStorage()).toMat43(1).toQuat()))  
                
            pkeys = []
            for posKey in boneAnimations.posKeys:
                pkeys.append(NoeKeyFramedValue(posKey.time, \
                    NoeVec3(posKey.pos.getStorage()))) 
          
            keyFramedBone.setRotation(rkeys)          
            keyFramedBone.setTranslation(pkeys)
        
            kfBones.append(keyFramedBone)
            index += 1        
        
        anims = []        
        anim = NoeKeyFramedAnim(boneAnimationsFile.filename, bones, kfBones, 1)
        anims.append(anim)
    

        mdl.setAnims(anims)
    
    mdl.setBones(bones)

    
    # set materials
    if materials:    
        mdl.setModelMaterials(NoeModelMaterials(textures, materials)) 
    mdlList.append(mdl)
    
    rapi.setPreviewOption("setAngOfs", "0 -90 0")
	
    return 1        