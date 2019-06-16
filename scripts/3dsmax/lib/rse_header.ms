/*

*/

filein "format_io.ms"

struct greHeader
(
  id = -1,
  size = -1,
  version = -1,
  name = ""
)


struct rseHeaderReader
(
  fstream,
  freader = formatReader(fstream),
  fn read rseHeader =
  (  
    local header = copy rseHeader
    if not (isKindof header greBoneHeader) and \
      not (isKindof header greWeightsHeader) then
      header.size = ReadLong fstream
    header.id = ReadLong fstream
    header.name = freader.readName() 
    if header.name == "Version" then
    (
      header.version = ReadLong fstream
      header.name = freader.readName()            
    )
    result = header
  )
)

struct rseHeaderWriter
(
  fstream,
  fWriter = formatWriter(fstream),
  fn write header =
  (
    if (hasProperty header size) then 
      WriteLong fstream header.size
    WriteLong fstream header.id
    if header.version > 0 then
    (
      fWriter.writeName "version"
      WriteLong fstream header.version      
    )
    fWriter.writeName header.name    
  )  
)