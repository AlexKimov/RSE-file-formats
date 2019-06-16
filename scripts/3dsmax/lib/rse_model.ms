/*

*/

struct rseModel
(
  fn createSceneObject group: =
  (
    objectArray = (if group != unsupplied then group else objects)
    
    geomObject = greGeometryObject()   
      
    for obj in objectArray do 
    (   
      if classof obj == Editable_mesh then
      (
        join geomObject.vertexArray (max.getMeshVerts obj)
        geomObject.vertexArray = makeUniqueArray geomObject.vertexArray          
        mesh = greMesh()
        
        for face in faceArray do 
        (
          
        )
        
        mesh.uvArray
        mesh.uvIndexArray
        mesh.vertexNormalArray
        mesh.faceColorArray
        append geomObject.meshes mesh
        
        mat = greMaterial()
        mat.params = 
        append object.materials mat
        tex = greTexture()
        tex.params = 
        append object.textures tex
        mesh = greMesh()  
        
        append object.geometryObjects geomObject            
      )
      if classof obj == Point then
      (
      
      )            
    )  
  )
)  