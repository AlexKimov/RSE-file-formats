from inc_noesis import *
import os
import noewin
import noewinext


SECTION_HEADER_SHORT = 0
SECTION_HEADER_LONG = 1 
COLOR_RGBA = 3
COLOR_RGB = 4


def registerNoesisTypes():
    handle = noesis.register( \
        "Rainbow Six (1998)/Rogue Spear (1999) level", ".map")
    
    noesis.addOption(handle, "-nogui", "disables UI", 0)   
    
    noesis.setHandlerTypeCheck(handle, rsMAPCheckType)
    noesis.setHandlerLoadModel(handle, rsMAPLoadModel)
        
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


class VertexData:
    def __init__(self):  
        self.normal = Vector3F()  
        self.uv = Vector2F()
        self.color = GREColor(COLOR_RGB, False) 
    
    
class FaceData:
    def __init__(self):  
        self.vertIndexes = vector3UI()
        self.vertDataIndexes = vector3UI()
        self.normal = Vector3F()
        self.materialIndex = 0
        
        
class RSMAPObject:    
    def __init__(self):  
        self.vertexes = []
        self.vertexData = []
        self.faceData = []  
        
    def read(self, reader):
        self.vertexCount = reader.readUInt()        
        for i in range(self.vertexCount): 
            vertex = Vector3F()
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
            
            
class RSMAP: 
    def __init__(self, reader):
        self.reader = reader
        self.textures = []
        self.materials = []
        self.objects = []
        
    def readFileHeader(self, reader):
        reader.seek(4, NOESEEK_REL)
        if reader.readString() != "BeginMapv2.1":        
            return 0
        reader.seek(4, NOESEEK_REL)
        
        return 1    
                
    def readMaterialList(self, reader):
        header = GREHeader()
        header.read(self.reader) 
        
        # materials
        count = reader.readUInt()
        for i in range(count):      
            mat = GRMaterial()
            mat.read(self.reader)
            
            self.materials.append(mat)
                                      
    def readGeometryList(self, reader):
        header = GREHeader()
        header.read(self.reader)      
        
        count = reader.readUInt()
        for i in range(count):
            header = GREHeader()
            header.read(self.reader) 
            reader.seek(8, NOESEEK_REL)
            
            model = RSMAPObject()  
            model.read(reader) 

            self.objects.append(model)
            print(self.reader.tell())            
            
    def read(self):
        if self.readFileHeader(self.reader) == 0:
            return 0

        self.readMaterialList(self.reader)  
        self.readGeometryList(self.reader)

        #self.reader.seek(4, NOESEEK_REL)
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
            
        
def rsMAPCheckType(data):

	return 1     
    

def rsMAPLoadModel(data, mdlList): 
    texturesPath = "C:/Games/Rainbow Six 2/data/texture/"
    
    # if not noesis.optWasInvoked("-nogui"): 
        # openDialog = GRModelViewSettingsDialogWindow()
        # openDialog.create()
    
        # if openDialog.isCanceled:
            # return 1
        
        # texturesPath = openDialog.options["TextureDir"]   
    
    rsLevel = RSMAP(NoeBitStream(data))
    if rsLevel.read() == 0:
        return 1
    
    ctx = rapi.rpgCreateContext()
    
    #transMatrix = NoeMat43( ((1, 0, 0), (0, 0, 1), (0, -1, 0), (0, 0, 0)) ) 
    #rapi.rpgSetTransform(transMatrix)      
    
    # load textures
    if rsLevel.materials:
        materials = []
        textures = [] 
        for material in rsLevel.materials:        
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
    for object in rsLevel.objects:
        for face in object.faceData:  
            if rsLevel.materials:
                rapi.rpgSetMaterial(rsLevel.materials[face.materialIndex].name)  
                
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
    
    #rapi.setPreviewOption("setAngOfs", "90 0 0")
	
    return 1        