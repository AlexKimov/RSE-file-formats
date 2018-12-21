/*
  Author: AlexKimov
  Version: 0.1
  Description: 
*/

filein "utils.ms"

struct iniFile
(
  filename,
  fn setValue section key value =
  (
    setINISetting filename section key (value as string)
  ),
  fn getValue section key =
  (
    getINISetting filename section key
  ),
  fn getIntegerValue section key =
  (
    strValue = getINISetting filename section key
	if strValue != "" then
      converter.stringToInteger(strValue)
	else
      result = -1	
  ),
   fn getBooleanValue section key =
  (
    strValue = getINISetting filename section key
	if strValue != "" then
      converter.stringToBoolean(strValue)
	else
      result = undefined	
  ), 
  fn getFloatValue section key =
  (
    strValue = getINISetting filename section key
	if strValue != "" then   
      converter.stringToFloat(strValue)
	else
      result = -1		  
  ),
  fn getArrayValue section key =
  (
    strValue = getINISetting filename section key
	if strValue != "" then     
      converter.stringToArray(strValue)
	else
      result = -1		   
  ),
  fn getPoint2Value section key =
  (
    strValue = getINISetting filename section key
	if strValue != "" then      
      converter.stringToPoint2 (strValue)
	else
      result = [0, 0]	  
  ),   
  fn isKeyExist section key =
  (
    hasINISetting filename section key      	  
  )
)

ini = iniFile()