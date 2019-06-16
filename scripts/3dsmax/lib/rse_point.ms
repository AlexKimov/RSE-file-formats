/*

*/

filein "rse.ms"
filein "format_io.ms"
filein "max.ms"

struct rsePointReader
(
  fstream,
  reader = formatReader(fstream), 
  fn read =
  (
    hPoint = grePoint()
    hPoint.name = freader.readName()
    hPoint.matrix = freader.readTransformationMatrix()
    result = hPoint
  )
)

struct rsePointWriter
(
  fstream,
  fwriter = formatWriter(fstream),  
  fn write helperPoint =
  (
    fwriter.writeName (helperPoint.name)
    fwriter.writeMatrix (helperPoint.matrix)  
  )
)