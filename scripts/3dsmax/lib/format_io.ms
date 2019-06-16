/*

*/

struct formatReader
(
  fstream,
  fn readBool longval:false =
  (
    if longval then
      result = (if (ReadLong fstream) > 0 then true else false)
    else
      result = (if (ReadByte fstream) > 0 then true else false)     
  ),
  fn readName =  
  (
    fseek fstream 4 #seek_cur
    result = ReadString fstream
  ),
  fn readIndexValues =
  (
    local index1 = (ReadShort fstream) + 1
    local index2 = (ReadShort fstream) + 1
    local index3 = (ReadShort fstream) + 1
    result = (point3 index1 index2 index3)
  ),  
  fn readColorValues alpha:true normalized:true =
  (
    -- color component value is in range 0..1
    normalCoeff = 1
    if normalized then
      normalCoeff = 255
    r = (ReadFloat fstream)*normalCoeff
    g = (ReadFloat fstream)*normalCoeff
    b = (ReadFloat fstream)*normalCoeff   
    if alpha then
    (
      a = (ReadFloat fstream)*normalCoeff  
      result = (color r g b a)
    )
    else
      result = (color r g b)    
  ),  
  fn readPoint2Values =  
  (
    result = (point2 (ReadFloat fstream) (ReadFloat fstream))  
  ),
  fn readPoint3Values =
  (
    result = (point3 (ReadFloat fstream) (ReadFloat fstream) \
      (ReadFloat fstream))
  ),
  fn readPoint4Values =
  (
    result = (point4 (ReadFloat fstream) (ReadFloat fstream) \
      (ReadFloat fstream) (ReadFloat fstream))
  ),  
  fn readQuatValues =
  (
    result = (quat (ReadFloat fstream) (ReadFloat fstream) \
      (ReadFloat fstream) (ReadFloat fstream))
  ),
  fn readMatrix = 
  (
    matrix = matrix3 1
    row = [(ReadFloat fstream), (ReadFloat fstream), (ReadFloat fstream)]
    matrix.row1 = row
    row = [(ReadFloat fstream), (ReadFloat fstream), (ReadFloat fstream)]
    matrix.row2 = row
    row = [(ReadFloat fstream), (ReadFloat fstream), (ReadFloat fstream)]
    matrix.row3 = row
    row = [(ReadFloat fstream), (ReadFloat fstream), (ReadFloat fstream)]
    matrix.row4 = row 
    result = matrix    
  )   
)

struct formatWriter
(
  fstream,
  fn writeBool boolValue =
  (
    if boolValue == true then 
      WriteByte fstream 1
    else 
      WriteByte fstream 0    
  ),  
  fn writeName name =  
  (
    WriteLong fstream (name.count + 1)
    WriteString fstream name
  ), 
  fn writeColor colorValues normalized:true =
  (
    if normalized then
      normalCoeff = 255
    ReadFloat fstream colorValues.r*normalCoeff
    ReadFloat fstream colorValues.g*normalCoeff
    ReadFloat fstream colorValues.b*normalCoeff       
  ),
  fn writePoint3Values point =
  (
    WriteFloat fstream point.x
    WriteFloat fstream point.y
    WriteFloat fstream point.z
  ), 
  fn writeQuatValues quatVar =
  (
    WriteFloat fstream quatVar.x
    WriteFloat fstream quatVar.y
    WriteFloat fstream quatVar.z
    WriteFloat fstream quatVar.w   
  ),
  fn writeMatrixValues matrix =
  (
    WriteFloat fstream matrix.row1.x 
    WriteFloat fstream matrix.row1.y
    WriteFloat fstream matrix.row1.z  
    WriteFloat fstream matrix.row2.x 
    WriteFloat fstream matrix.row2.y
    WriteFloat fstream matrix.row2.z  
    WriteFloat fstream matrix.row3.x 
    WriteFloat fstream matrix.row3.y
    WriteFloat fstream matrix.row3.z  
    WriteFloat fstream matrix.row4.x 
    WriteFloat fstream matrix.row4.y
    WriteFloat fstream matrix.row4.z      
  )  
)