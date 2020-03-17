from inc_noesis import *
import os
import noewin
import noewinext


SECTION_HEADER_SHORT = 0
SECTION_HEADER_LONG = 1 


def registerNoesisTypes():
    handle = noesis.register( \
        "Rogue Spear (1999) dynamic model", ".rob")
    
    noesis.addOption(handle, "-nogui", "disables UI", 0)   
    
    noesis.setHandlerTypeCheck(handle, rspDynamicModelCheckType)
    noesis.setHandlerLoadModel(handle, rspDynamicModelLoadModel)
        
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
       
       
class Matrix4x4:
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
        self.textureName = ""
        self.name = ""
        
    def read(self, reader):
        header = GREHeader()
        header.read(reader) 
        
        self.name = header.name
        
        reader.seek(4, NOESEEK_REL)
        self.textureName = reader.readString() 
        
        self.opacity = reader.readFloat()                        
        reader.seek(8, NOESEEK_REL)

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
            
    
class RSPMesh:
    def __init__(self):  
        self.uvs = []
        self.faceIndexes = []
        self.textureIndexes = []
    
    def read(self, reader):          
        self.materialIndex = reader.readUInt()                 

        count = reader.readUInt()          
        reader.seek(16 * count, NOESEEK_REL) # normals?
                
        for i in range(count):
            indexes = Vector3UI16() 
            indexes.read(reader)              
            self.faceIndexes.append(indexes)
            
        for i in range(count):
            indexes = Vector3UI16() 
            indexes.read(reader)              
            self.textureIndexes.append(indexes)   

        count = reader.readUInt()       
        reader.seek(12 * count, NOESEEK_REL) # normals          
        
        for i in range(count):
            uv = Vector2F() 
            uv.read(reader)              
            self.uvs.append(uv) 

        reader.seek(16 * count, NOESEEK_REL) #colors       

        
class RSPObject:    
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
            modelMesh = RSPMesh()
            modelMesh.read(reader)

            self.meshes.append(modelMesh)

        # skip unknown data
        reader.seek(8, NOESEEK_REL)         
        count = reader.readUInt()         
        reader.seek(16 * count, NOESEEK_REL)          
        reader.seek(8, NOESEEK_REL)
        reader.readString()        
        reader.seek(4, NOESEEK_REL) 
        count = reader.readUInt() 
        reader.seek(2 * count, NOESEEK_REL) 
            
            
class RSDynamicModel: 
    def __init__(self, reader):
        self.reader = reader
        self.textures = []
        self.materials = []
        self.models = []
        
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
            mat = GRMaterial()
            mat.read(self.reader)
            
            self.materials.append(mat)
                             
            
    def readGeometryList(self, reader):
        header = GREHeader()
        header.read(self.reader)      
        
        count = self.reader.readUInt()
        for i in range(count):
            header = GREHeader()
            header.read(self.reader) 
            header.read(self.reader) 
            
            model = RSPObject()  
            model.read(reader) 

            self.models.append(model)            
            
    def read(self):
        if self.readFileHeader(self.reader) == 0:
            return 0
            
        self.readMaterialList(self.reader)
        noesis.logPopup()
        self.readGeometryList(self.reader)
        
        self.reader.seek(4, NOESEEK_REL)
        #if self.reader.readString() != "EndModel":        
            #return 0                              
          

class GRModelViewSettingsDialogWindow:
    def __init__(self):
        self.options = {"TextureDir": ""}
        self.isCanceled = True
        self.texturePathEditBox = None

    def buttonGetTexturePathOnClick(self, noeWnd, controlId, wParam, lParam):
        dialog = noewinext.NoeUserOpenFolderDialog("Choose folder with texture files")
        folder = dialog.getOpenFolderName() 

        if folder != None:
            self.texturePathEditBox.setText(folder)
                     
        return True

    def buttonLoadOnClick(self, noeWnd, controlId, wParam, lParam):    
        self.options["TextureDir"] = self.texturePathEditBox.getText()
        self.options["TextureDir"] = "F:\SteamLibrary\steamapps\common\Ghost Recon\Mods\Mp2\Textures"
            
        self.isCanceled = False
        self.noeWnd.closeWindow()   

        return True

    def buttonCancelOnClick(self, noeWnd, controlId, wParam, lParam):
        self.isCanceled = True
        self.noeWnd.closeWindow()

        return True

    def create(self):
        self.noeWnd = noewin.NoeUserWindow("Load Ghost Recon qob model", "openModelWindowClass", 385, 120)
        noeWindowRect = noewin.getNoesisWindowRect()

        if noeWindowRect:
            windowMargin = 100
            self.noeWnd.x = noeWindowRect[0] + windowMargin
            self.noeWnd.y = noeWindowRect[1] + windowMargin

        if self.noeWnd.createWindow():
            self.noeWnd.setFont("Arial", 12)

            self.noeWnd.createStatic("Path to texture folder", 5, 5, 180, 20)
            # choose path to textures
            index = self.noeWnd.createEditBox(5, 28, 275, 20, "", None, False, False)
            self.texturePathEditBox = self.noeWnd.getControlByIndex(index)

            self.noeWnd.createButton("Open", 290, 27, 80, 21, self.buttonGetTexturePathOnClick)
            
            self.noeWnd.createButton("Load", 5, 60, 80, 30, self.buttonLoadOnClick)
            self.noeWnd.createButton("Cancel", 90, 60, 80, 30, self.buttonCancelOnClick)

            self.noeWnd.doModal()
            
        
def rspDynamicModelCheckType(data):

	return 1     
    

def rspDynamicModelLoadModel(data, mdlList): 
    texturesPath = "C:/Games/Rainbow Six 2/data/texture/"
    
    # if not noesis.optWasInvoked("-nogui"): 
        # openDialog = GRModelViewSettingsDialogWindow()
        # openDialog.create()
    
        # if openDialog.isCanceled:
            # return 1
        
        # texturesPath = openDialog.options["TextureDir"]   
    
    rspDynamicModel = RSDynamicModel(NoeBitStream(data))
    if rspDynamicModel.read() == 0:
        return 1
    
    ctx = rapi.rpgCreateContext()
    
    #transMatrix = NoeMat43( ((1, 0, 0), (0, 0, 1), (0, -1, 0), (0, 0, 0)) ) 
    #rapi.rpgSetTransform(transMatrix)      
    
    # load textures
    if rspDynamicModel.materials:
        materials = []
        textures = [] 
        for material in rspDynamicModel.materials:        
            filename = material.textureName.split(".")[0]            
            textureName = "{}/{}.rsb".format(texturesPath, filename)               
            texture = rapi.loadExternalTex(textureName)
            if texture == None:
                texture = NoeTexture(textureName, 0, 0, bytearray())

            textures.append(texture)            
            material = NoeMaterial(material.name, textureName)
            material.setFlags(noesis.NMATFLAG_TWOSIDED, 1)
            materials.append(material) 
      
    # show meshes
    for model in rspDynamicModel.models:
        for msh in model.meshes:        
            if materials:
                rapi.rpgSetMaterial(rspDynamicModel.materials[msh.materialIndex].name)  
                
            rapi.immBegin(noesis.RPGEO_TRIANGLE)
            
            for i in range(len(msh.faceIndexes)):
                textIndexes = msh.textureIndexes[i]
                faceIndexes = msh.faceIndexes[i]
                
                for k in range(3):
                    tIndex = textIndexes.getStorage()[k]
                    uv =  msh.uvs[tIndex]
                    rapi.immUV2(uv.getStorage()) 
                    
                    vIndex = faceIndexes.getStorage()[k]                
                    vertex =  model.vertexes[vIndex]           
                    rapi.immVertex3(vertex.getStorage())        
                    
            rapi.immEnd()              

    mdl = rapi.rpgConstructModelSlim()

    # set materials
    if materials:    
        mdl.setModelMaterials(NoeModelMaterials(textures, materials)) 
    mdlList.append(mdl)
    
    #rapi.setPreviewOption("setAngOfs", "90 0 0")
	
    return 1        