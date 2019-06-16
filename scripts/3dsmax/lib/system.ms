/*

*/

struct systemUtils
(
  fn getDateTimeinSeconds =
  (
    epochDateTime = dotnetObject "System.DateTime" 1970 1 1 0 0 0 
    curDateTime = (dotNetClass "System.DateTime").Now.Subtract(epochDateTime)
    result = (curDateTime.TotalSeconds as integer)
  )
)

struct maxSystem
(
  currentPath = "",
  utils = systemUtils()
)


sys = maxSystem()