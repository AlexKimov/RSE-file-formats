/*
  Author: AlexKimov
  Version: 0.1
  Description:
*/

filein "utils.ms"

struct dialogs
(
  caption = "",
  types = "",
  fn isValue txt =
  (
    if txt != "" then
    (
      try
      (
        val = execute txt
        result = true
      )
      catch 
      (
        messageBox "ERROR. Not a number: " + txt + "."
        result = false
      )
    )  
    else 
      result = false        
  ),
  fn isNonNegativeValue txt =
  (
    value = converter.stringToInteger txt
    if value <= 0 then 
    (
      messageBox ("Error. Value: " + txt + " must be greater than or equal to zero.")
      result = false
    )  
    else
      result = true  
  ),  
  fn checkInputValue txt checkType =
  (  
    result = false
    if isValue txt then  
      result = isnNonNegativeValue txt         
  ),  
  fn openFileDialog &filename mode =
  (
  	if filename == undefined or filename == "" then
      filename = 
      (      
	    if mode == "rb" then 
          getOpenFileName caption: caption types: types
	    else
          getSaveFileName caption: caption types: types
      )  
	if filename != undefined then
      filestream = fopen filename mode 
  ), 
  fn saveFile =
  (
  
  ),   
  fn openFolder caption =
  (
    getSavePath caption: caption
  ),
  fn showMessage caption =
  (
    messageBox caption
  )  
)

dialogs = dialogs()