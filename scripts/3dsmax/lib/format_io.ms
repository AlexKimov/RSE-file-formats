/*

*/

struct formatReader
(
  filestream,
  fn readName =  
  (
    fseek filestream 4 #seek_cur
    result = ReadString filestream
  ),
  fn readIndexValues =
  (
    local index1 = (ReadShort filestream) + 1
    local index2 = (ReadShort filestream) + 1
    local index3 = (ReadShort filestream) + 1
    result = (point3 index1 index2 index3)
  ),  
  fn readColorValues alpha:true normalized:true =
  (
    -- color component value is in range 0..1
    normalCoeff = 1
    if normalized then
      normalCoeff = 255
    r = (ReadFloat filestream)*normalCoeff
    g = (ReadFloat filestream)*normalCoeff
    b = (ReadFloat filestream)*normalCoeff   
    if alpha then
    (
      a = (ReadFloat filestream)*normalCoeff  
      result = (color r g b a)
    )
    else
      result = (color r g b)    
  ),  
  fn readPoint3Values =
  (
    result = (point3 (ReadFloat filestream) (ReadFloat filestream) \
      (ReadFloat filestream))
  ),
  fn readPoint4Values =
  (
    result = (point4 (ReadFloat filestream) (ReadFloat filestream) \
      (ReadFloat filestream) (ReadFloat filestream))
  ),  
  fn readQuatValues =
  (
    result = (quat (ReadFloat filestream) (ReadFloat filestream) \
      (ReadFloat filestream) (ReadFloat filestream))
  ),
  fn readMatrix = 
  (
    matrix = matrix3 1
    row = [(ReadFloat filestream), (ReadFloat filestream), (ReadFloat filestream)]
    matrix.row1 = row
    row = [(ReadFloat filestream), (ReadFloat filestream), (ReadFloat filestream)]
    matrix.row2 = row
    row = [(ReadFloat filestream), (ReadFloat filestream), (ReadFloat filestream)]
    matrix.row3 = row
    row = [(ReadFloat filestream), (ReadFloat filestream), (ReadFloat filestream)]
    matrix.row4 = row 
    result = matrix    
  )  
)