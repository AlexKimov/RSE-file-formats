/*
  Author: AlexKimov
  Description: 
*/

struct converter (
  fn arrayValuesToString valueArray =
  (
    if valueArray.count > 1 then
    (
      str = valueArray[1] as string
      for i = 2 to valueArray.count do
        str +=  "," + (valueArray[i] as string)
      result = "(" + str + ")"
    )
    else
      result = valueArray[1] as string
  ),
  fn stringToPoint2 str = 
  (
    elements = filterstring str "[,]"
	if elements.count > 0 then
	(
	  try
      (	  
        first = elements[1] as integer
        second = elements[2] as integer
	  ) 
	  catch 
	  (
	    messageBox "Error. Can't convert: " + str + " to Point2 value"
	  )
      pointTwo = [first, second]
	)
	else
	(
	  --messageBox "Error. Can't convert: " + str + " to Point2 value"
	  [0, 0]
	)	  
  ),
  fn stringToInteger str = 
  (
    try
    (	  
      str as integer
    )
    catch 
	(
	  --messageBox "Error. Can't convert: " + str + " to integer value"
	  -1
	)
  ),
  fn stringToFloat str = 
  (
    try
    (	  
      str as float
	)  
    catch 
	(
	  --messageBox "Error. Can't convert: " + str + " to float value"
	  -1
	)	
  ), 
  fn stringToBoolean str = 
  (
    try
    (	  
      str as boolean
	)  
    catch 
	(
	  --messageBox "Error. Can't convert: " + str + " to boolean value"
	  -1
	)	
  ),   
  fn stringToArray str = 
  (
    array = #()
    elements = filterstring str "(,)"
	if elements.count > 0 then
	  for element in elements do
        append array (element as name)
   	array  
  )
)

struct fileUtils
(
  fn isFileExist filename =
  (
    result = doesFileExist filename
  ), 
  fn getFileExtenion filename =
  (
    result = getFilenameType filename
  ),
  fn getCurrentPath filename =
  (
    result = getFilenamePath filename
  ),
  fn getFileName filename ext:false =
  (
    if ext then
      filenameFromPath filename
    else
      getFilenameFile filename
  ),
  fn findFiles directory pattern subfolders:false =
  (
    local files = #()  
    if subfolders then
    (
      dir_array = GetDirectories (directory + "/*")
      for dir in dirArray do
        join dirArray (GetDirectories (dir + "/*"))
      for file in dirArray do
        join files (getFiles (file + pattern)) 
    )
    else
      files = getFiles (directory + pattern)
    result = files  
  )  
 )
 
fileUtils = fileUtils()
converter = converter()