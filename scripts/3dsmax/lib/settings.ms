/*
  Author: AlexKimov
  Version: 0.1
  Description: 
*/

filein "utils.ms"
filein "ini.ms"

struct settings
(
  properties,
  iniFile = "settings.ini",
  fn saveToIniFile filename iniSectionTitle =
  (    
    ini.filename = iniFile    
	if fileUtils.isFileExist filename then    
      ini.filename = filename  
   
	if fileUtils.isFileExist ini.filename then 
    (
      local strValue
      names = getPropNames properties
      for name in names do
      (
        strName = name as string
        if ini.isKeyExist iniSectionTitle strName then
        (
          prop = getProperty properties name
          propClass = classof prop
          case propClass of 
          (        
            Array:
            (
              local str = convertor.arrayValuesToString prop
              ini.setValue iniSectionTitle strName str       
            )                
            default:
              ini.setValue iniSectionTitle strName (prop as string)                     
          )                     
        )
      ) 
    )     
  ),  
  fn loadFromIniFile filename iniSectionTitle =
  (
    local intValue = 0
    local array = #()
    local point = [0, 0]
    local strValue = ""
    local boolValue = true
    
    ini.filename = iniFile    
	if fileUtils.isFileExist filename then    
      ini.filename = filename  
   
	if fileUtils.isFileExist ini.filename then 
    (
      local strValue
      names = getPropNames properties
      for name in names do
      (
        strName = name as string
        if ini.isKeyExist iniSectionTitle strName then
        (
          prop = getProperty properties name
          propClass = classof prop
          case propClass of 
          (        
            Integer:
            (
              intValue = ini.getIntegerValue iniSectionTitle strName
              if intValue > 0 then
                setProperty properties name intValue             
            )
            Array:
            (
              array = ini.getArrayValue iniSectionTitle strName
              if array.count > 0 then
                setProperty properties name array             
            )                
            Point2: 
            (
              point = ini.getPoint2Value iniSectionTitle strName
              if point.x > 0 then
                setProperty properties name point            
            ) 
            BooleanClass: 
            (
              boolValue = ini.getBooleanValue iniSectionTitle strName
              if boolValue != undefined then
                setProperty properties name boolValue  
            )    
            -- String, Value, etc...
            default:
            (
              strValue = ini.getValue iniSectionTitle strName
              if strValue != "" then
                setProperty properties name strValue             
            )            
          )                     
        )
      ) 
    )   
  )
)
