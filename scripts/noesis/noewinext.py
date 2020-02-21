import ctypes
import ctypes.wintypes as wintypes
import noewin

OFN_ALLOWMULTISELECT = 0x00000200
OFN_ENABLESIZING     = 0x00800000
OFN_PATHMUSTEXIST    = 0x00000800
OFN_OVERWRITEPROMPT  = 0x00000002
OFN_NOCHANGEDIR      = 0x00000008
OFN_FILEMUSTEXIST    = 0x00001000
MAX_PATH             = 1024

TVI_ROOT            = 0xFFFF0000
TVI_FIRST           = 0xFFFF0001
TVI_LAST            = 0xFFFF0002

TV_FIRST            = 0x1100
TVM_INSERTITEM      = TV_FIRST
TVM_DELETEITEM      = (TV_FIRST + 1)
TVM_GETNEXTITEM     = (TV_FIRST + 10)
TVM_GETITEM         = (TV_FIRST + 12)

TVGN_CARET          = 9
TVGN_PARENT         = 3

TVIF_TEXT           = 1
TVIF_IMAGE          = 2
TVIF_SELECTEDIMAGE  = 32
TVIF_PARAM          = 4

TVS_LINESATROOT     = 4
TVS_HASBUTTONS      = 1
TVS_HASLINES        = 2 

DIB_RGB_COLORS      = 0

STM_SETIMAGE        = 0xF172

PBS_SMOOTH	        = 1

WM_USER             = 0x0400
PBM_SETRANGE	    = (WM_USER + 1)
PBM_SETSTEP	        = (WM_USER + 4)
PBM_SETPOS	        = (WM_USER + 2)

BS_GROUPBOX         = 0x00000007

BFFM_INITIALIZED = 1
BFFM_SETSELECTIONA = WM_USER + 102
BFFM_SETSELECTIONW = WM_USER + 103
BIF_RETURNONLYFSDIRS = 0x00000001
BIF_NEWDIALOGSTYLE = 0x00000040
BFFCALLBACK = ctypes.WINFUNCTYPE(ctypes.c_int, wintypes.HWND, ctypes.c_uint, wintypes.LPARAM, wintypes.LPARAM)

LPOFNHOOKPROC = ctypes.c_voidp
LPCTSTR = LPTSTR = ctypes.c_wchar_p
LPCSTR = LPSTR = ctypes.c_char_p
HTREEITEM = wintypes.HANDLE
LPVOID = ctypes.c_voidp

class BITMAPINFOHEADER(ctypes.Structure):
    _fields_ = [('biSize', wintypes.DWORD),
                ('biWidth', wintypes.LONG),
                ('biHeight', wintypes.LONG),
                ('biPlanes', wintypes.WORD),
                ('biBitCount', wintypes.WORD),
                ('biCompression', wintypes.DWORD),
                ('biSizeImage', wintypes.DWORD),
                ('biXPelsPerMeter', wintypes.LONG),
                ('biYPelsPerMeter', wintypes.LONG),
                ('biClrUsed', wintypes.DWORD),
                ('biClrImportant', wintypes.DWORD)]
 
 
class RGBQUAD(ctypes.Structure):
    _fields_ = [('rgbRed', ctypes.c_byte),
                ('rgbGreen', ctypes.c_byte),
                ('rgbBlue', ctypes.c_byte),
                ('rgbReserved', ctypes.c_byte)] 
        
        
class BITMAPINFO(ctypes.Structure):
    _fields_ = [('bmiHeader', BITMAPINFOHEADER),
                ('bmiColors', ctypes.POINTER(RGBQUAD))]        


class TVITEM(ctypes.Structure):
    _fields_ = [("mask", wintypes.UINT),
                ("hItem", HTREEITEM),
                ("state", wintypes.UINT),
                ("stateMask", wintypes.UINT),
                ("pszText", LPTSTR),
                ("cchTextMax", wintypes.INT),
                ("iImage", wintypes.INT),
                ("iSelectedImage", wintypes.INT),
                ("cChildren", wintypes.INT),
                ("lParam", wintypes.LPARAM)]
 

class TVINSERTSTRUCT(ctypes.Structure):
    _fields_ = [("hParent", HTREEITEM),
                ("hInsertAfter", HTREEITEM),
                ("item", TVITEM)]                  

                
class OPENFILENAME(ctypes.Structure):
    _fields_ = [("lStructSize", wintypes.DWORD),
                ("hwndOwner", wintypes.HWND),
                ("hInstance", wintypes.HINSTANCE),
                ("lpstrFilter", LPCTSTR),
                ("lpstrCustomFilter", LPTSTR),
                ("nMaxCustFilter", wintypes.DWORD),
                ("nFilterIndex", wintypes.DWORD),
                ("lpstrFile", LPTSTR),
                ("nMaxFile", wintypes.DWORD),
                ("lpstrFileTitle", LPTSTR),
                ("nMaxFileTitle", wintypes.DWORD),
                ("lpstrInitialDir", LPCTSTR),
                ("lpstrTitle", LPCTSTR),
                ("flags", wintypes.DWORD),
                ("nFileOffset", wintypes.WORD),
                ("nFileExtension", wintypes.WORD),
                ("lpstrDefExt", LPCTSTR),
                ("lCustData", wintypes.LPARAM),
                ("lpfnHook", LPOFNHOOKPROC),
                ("lpTemplateName", LPCTSTR),
                ("pvReserved", wintypes.LPVOID),
                ("dwReserved", wintypes.DWORD),
                ("flagsEx", wintypes.DWORD)]


class BROWSEINFO(ctypes.Structure):
    _fields_ = [("hwndOwner", wintypes.HWND),
                ("pidlRoot", LPVOID),
                ("pszDisplayName", LPTSTR),
                ("lpszTitle", LPCTSTR),
                ("ulFlags", wintypes.UINT),
                ("lpfn", BFFCALLBACK),
                ("lParam", wintypes.LPARAM),
                ("iImage", wintypes.INT)]


def MAKELONG(a, b):
    return (a & 0xffff) | ((b & 0xffff) << 16)


class NoeUserOpenFolderDialog(ctypes.Structure):
    def __init__(self, title=""):
        self.bi = BROWSEINFO()
        self.bi.hwndOwner = 0
        self.bi.pidlRoot = 0
        strBuffer = ctypes.create_string_buffer(title.encode('ascii'))
        self.bi.lpszTitle = ctypes.cast(strBuffer, LPCTSTR)
        self.bi.ulFlags = BIF_RETURNONLYFSDIRS | BIF_NEWDIALOGSTYLE
        self.bi.iImage = 0
    
    def getOpenFolderName(self):
        result = None
        
        pidl = ctypes.windll.shell32.SHBrowseForFolder(ctypes.byref(self.bi))
        try:
            if pidl:  
                buffer = ctypes.create_string_buffer(MAX_PATH)       
                path = ctypes.cast(buffer, LPSTR)
                if ctypes.windll.shell32.SHGetPathFromIDList(pidl, path):
                    result = path.value.decode('ascii')
        finally:       
            ctypes.windll.ole32.CoTaskMemFree(pidl)
            
        return result    
        
        
class NoeUserDialog(ctypes.Structure): 
    def __init__(self, title="", default_extension="", filter_string="", initialPath="", allowMultiSelect=False):
        filterString = filter_string.replace("|", "\0")
        self.fileBuffer = ctypes.create_unicode_buffer(initialPath, MAX_PATH)  
        
        self.ofn = OPENFILENAME()
        self.ofn.lStructSize = ctypes.sizeof(OPENFILENAME)
        self.ofn.lpstrTitle = title
        self.ofn.lpstrFile = ctypes.cast(self.fileBuffer, LPTSTR)
        self.ofn.nMaxFile = MAX_PATH
        self.ofn.lpstrDefExt = default_extension
        self.ofn.lpstrFilter = filterString
        self.ofn.Flags = OFN_ENABLESIZING | OFN_PATHMUSTEXIST | OFN_OVERWRITEPROMPT | OFN_NOCHANGEDIR
        if allowMultiSelect:   
            self.ofn.Flags |= OFN_ALLOWMULTISELECT                    

    def setTitle(self, title):
        self.ofn.lpstrTitle = title

    def setDefaultExtension(self, extension):
        self.ofn.lpstrDefExt = extension

    def setFilterString(self, filterStr):
        self.ofn.lpstrFilter = filterStr.replace("|", "\0")

    def setInitialPath(self, initialPath):
        self.fileBuffer = ctypes.create_unicode_buffer(initialPath, MAX_PATH)
        self.ofn.lpstrFile = ctypes.cast(self.fileBuffer, LPTSTR)        
        
    def allowMultiSelect(self, status):
        if self.ofn.Flags and OFN_ALLOWMULTISELECT: 
            if not status:
                self.ofn.Flags -= OFN_ALLOWMULTISELECT
        else:                 
            if status:
                self.ofn.Flags |= OFN_ALLOWMULTISELECT
                
    def getOpenFileName(self):        
        GetOpenFileName = ctypes.windll.comdlg32.GetOpenFileNameW
        if GetOpenFileName(ctypes.byref(self.ofn)):
            return self.fileBuffer[:]
        else:
            return None
  
    def getSaveFileName(self):  
        GetSaveFileName = ctypes.windll.comdlg32.GetSaveFileNameW  
        if GetSaveFileName(ctypes.byref(self.ofn)):
            return self.fileBuffer[:]
        else:
            return None


class NoeUserProgressBar(noewin.NoeUserControlBase):
    def __init__(self, noeParentWnd, name, controlId, x, y, width, height, commandMethod):
        self.name = name
        self.style = WS_CHILD | WS_VISIBLE | PBS_SMOOTH
        self.hWnd = ctypes.windll.user32.CreateWindowExW(0, "MSCTLS_PROGRESS32", self.name, self.style, x, y, width,
                                                         height, noeParentWnd.hWnd, self.controlId, noeParentWnd.hInst,
                                                         0)
            
        ctypes.windll.user32.SendMessageW(self.hWnd, PBM_SETRANGE, 0, MAKELONG(0, 100))
        ctypes.windll.user32.SendMessageW(self.hWnd, PBM_SETSTEP, 1, 0)              
    
    def setRange(position, range):
        ctypes.windll.user32.SendMessageW(self.hWnd, PBM_SETRANGE, 0, MAKELONG(0, range))

    def setPosition(position):
        ctypes.windll.user32.SendMessageW(self.hWnd, PBM_SETPOS, position, 0)
            
        
class NoeUserStaticImage(noewin.NoeUserControlBase):
    def __init__(self, noeParentWnd, name, controlId, x, y, width, height, commandMethod):
        self.name = name
        self.style = WS_OVERLAPPEDWINDOW | WS_VISIBLE
        self.hWnd = ctypes.windll.user32.CreateWindowExW(0, "STATIC IMAGE", self.name, self.style, x, y, width, height,
                                                         noeParentWnd.hWnd, self.controlId, noeParentWnd.hInst, 0)
            
    def showImage(width, height, imageData): 
        bmi = BITMAPINFO()
        bmi.bmiHeader.biSize = ctypes.sizeof(BITMAPINFOHEADER)
        bmi.bmiHeader.biWidth = width
        bmi.bmiHeader.biHeight = height
        bmi.bmiHeader.biPlanes = 4
        bmi.bmiHeader.biBitCount = 32
        bmi.bmiHeader.biCompression = 0 
        bmi.bmiHeader.biSizeImage = 0     
    
        #hDC = GetDC(self.hWnd)        
        #try:
        #    hBitmap = CreateCompatibleBitmap(hDC, width, height)  
        #    SetDIBits(hDC, byref(hBitmap), 0, height, imageData, byref(bmi), DIB_RGB_COLORS)
            #ctypes.windll.user32.SendMessageW(self.hWnd, STM_SETIMAGE, IMAGE_BITMAP,\ 
            #    byref(hBitmap))
        #    DeleteObject(hBitmap)                 
        #finally:
        #    DeleteDC(hDC)             
            
            
class NoeUserTreeView(noewin.NoeUserControlBase):
    def __init__(self, noeParentWnd, name, controlId, x, y, width, height, commandMethod):
        super().__init__(noeParentWnd, controlId, x, y, width, height, commandMethod)
        self.name = name
        self.style = noewin.WS_VISIBLE | noewin.WS_CHILD | noewin.WS_BORDER | TVS_HASLINES | TVS_LINESATROOT |\
                     TVS_HASBUTTONS
        self.hWnd = ctypes.windll.user32.CreateWindowExW(0, "SysTreeView32", self.name, self.style, x, y, width, height,
                                                         noeParentWnd.hWnd, self.controlId, noeParentWnd.hInst, 0)
            
    def insertItem(self, text, parentItem = None):    
        tvi = TVITEM()
        tvi.mask = TVIF_TEXT     
        
        buffer = ctypes.create_string_buffer(text.encode('utf-8'))
        tvi.pszText = ctypes.cast(buffer, LPTSTR)
        tvi.cchTextMax = 256
    
        tvins = TVINSERTSTRUCT()
        tvins.item = tvi
        tvins.hInsertAfter = TVI_LAST 
        if parentItem == None:      
            tvins.hParent = TVI_ROOT 
        else:
            tvins.hParent = parentItem         
        
        return ctypes.windll.user32.SendMessageW(self.hWnd, TVM_INSERTITEM, 0, ctypes.byref(tvins))
   
    def removeItem(self, item):       
        ctypes.windll.user32.SendMessageW(self.hWnd, TVM_DELETEITEM, 0, item)    

    def clear(self):
        ctypes.windll.user32.SendMessageW(self.hWnd, TVM_DELETEITEM, 0, TVI_ROOT)
        
    def getParent(self, item):
        return ctypes.windll.user32.SendMessageW(self.hWnd, TVM_GETNEXTITEM, TVGN_PARENT, item)
        
    def getItemText(self, item):
        tvi = TVITEM()
        tvi.mask = TVIF_TEXT
        tvi.cchTextMax = 256 
        
        buffer = ctypes.create_string_buffer(256)        
        tvi.pszText = ctypes.cast(buffer, LPTSTR)  
        
        tvi.hItem = item        
        ctypes.windll.user32.SendMessageW(self.hWnd, TVM_GETITEM, 0, ctypes.byref(tvi))

        return str(buffer[:].partition(b'\0')[0], encoding="utf-8")
                
           
    def selected(self):
        return ctypes.windll.user32.SendMessageW(self.hWnd, TVM_GETNEXTITEM, TVGN_CARET, 0)
        
    #def setText(self, item, text):
        #tvi = getItem(item)            
       
    
class NoeUserGroupBox(noewin.NoeUserControlBase):
    def __init__(self, noeParentWnd, name, controlId, x, y, width, height, commandMethod):
        super().__init__(noeParentWnd, controlId, x, y, width, height, commandMethod)
        self.name = name      
        self.style = noewin.WS_CHILD | noewin.WS_VISIBLE | BS_GROUPBOX
        self.hWnd = ctypes.windll.user32.CreateWindowExW(0, "Button", self.name, self.style, x, y, width, height,
                                                         noeParentWnd.hWnd, self.controlId, noeParentWnd.hInst, 0)

            
class NoeUserWindowExt(noewin.NoeUserWindow):
    def __init__(self, windowName, windowClassName, windowWidth = 0, windowHeight = 0): 
        super().__init__(windowName, windowClassName, windowWidth, windowHeight)
            
    def createTreeView(self, x, y, width, height, name = "", commandMethod = None):
        if self.hWnd:        
            newTreeView = NoeUserTreeView(self, name, self.currentControlId, x, y, width, height, commandMethod)
            return self.addControl(newTreeView)
            
        return -1   

    def createPogressBar(self, x, y, width, height, name = "", commandMethod = None):
        if self.hWnd:        
            newTreeView = NoeUserTreeView(self, name, self.currentControlId, x, y, width, height, commandMethod)
            return self.addControl(newTreeView)
            
        return -1    

    def createStaticImage(self, x, y, width, height, name = "", commandMethod = None):
        if self.hWnd:        
            newTreeView = NoeUserTreeView(self, name, self.currentControlId, x, y, width, height, commandMethod)
            return self.addControl(newTreeView)
            
    def createGroupBox(self, x, y, width, height, name = "", commandMethod = None):
        if self.hWnd:        
            newGroupBox = NoeUserGroupBox(self, name, self.currentControlId, x, y, width, height, commandMethod)
            return self.addControl(newGroupBox)            
            
        return -1           