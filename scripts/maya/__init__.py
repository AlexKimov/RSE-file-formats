import os.path as path
import traceback
#import logging
import sys

app = path.split(sys.executable)[1]

if 'maya' in app.lower():
    import maya.cmds 

    try:
        from .rse_maya import maya_ui

        reload(maya_ui)
        maya_ui.main()
    except Exception as e:
        traceback.print_exc()
        raise e