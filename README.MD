## About

010 Editor file templates and format specs for the games by Red Storm Entertainment. Current available file templates are listed below.

About file formats [see WIKI page](https://github.com/AlexKimov/010Editor-Templates-GR/wiki). Current progress status [see Issues](https://github.com/AlexKimov/RSE-file-formats/issues?q=is%3Aissue+is%3Aopen+label%3Aprogress).

#### Roadmap

* 3dsmax import/export scripts ([link](https://github.com/AlexKimov/RSE-file-formats/issues/28));
* conversion scripts ([link](https://github.com/AlexKimov/RSE-file-formats/issues/28));

#### Discussions
* ghostrecon.net forum ([link](http://www.ghostrecon.net/forums/index.php?/topic/61545-gr-community-sdk/));

## File Converters 
* Python scripts and even more by Philip Edwards 
https://github.com/boristsr/RainbowSixFileConverters.

## Games and formats

| №     | Game | Platform | Year | File extensions |
| :--- | :-- | :------ | :------ | :------ |
| 1 | Rainbow six Lockdown | PC | 2005 | .rsb, .chr, .skl, .qob |
| 2 | Ghost Recon 2 Summit Strike | XBOX | 2005  | .xpr |
| 3 | Ghost Recon 2 | XBOX | 2004  | .xpr |
| 4 | Tom Clancy's Ghost Recon Island Thunder | XBOX | 2002  | .rsb |
| 5 | Tom Clancy's Ghost Recon | PS2 | 2002  | .rsb |
| 6 | The Sum of All Fears | PC  |2002 | .chr, .map, .pob, .qob, .rsb, .anm, .bmf  |
| 7 | Ghost Recon (Desert Siege, Island Thunder) | PC |2001 - 2003 | .chr, .map, .pob, .qob, .rsb, .anm, .bmf  |
| 8 | Freedom First Resistance  | PC | 2000  | .rsb, .map, .qob, .noz, .rsa, .dam |
| 9 | Rogue Spear (Urban Operations, Covert Ops, Black Thorn) | PC |1999 - 2001  | .rsb, .map, .sob, .rob, .qob, .skl, .dam, .dmp |
| 10 | Shadow Watch  | PC | 2000  | .r16, .smf  |
| 11 | Force 21  | PC | 1999  | .rsb, .kit, .gee, .tgz  |
| 12 | Dominant Species  |  PC | 1998 | .rsb, .crp, .cmf, .dam  |
| 13 | Rainbow six (Eagle Watch) | PC | 1998 |  .rsb, .crp, .skl, .sob, .bcl, .map, .dam  |

## Templates and scripts (wip)

**1. Ghost Recon 1, The Sum Of All Fears**

| № | Format       | Template name     | Progress     | Specs | Description |
| :--- | :--------- | :----------- | :---------- | :---------- | :---------- |
| 1 | .anm        | [ANM(gr).bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/ANM(gr).bt)        | **100%**      | [ANM file format](https://github.com/AlexKimov/RSE-file-formats/wiki/ANM-File-Format)          |  Animation data |
| 2 | .bmf        | [BMF.bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/BMF.bt)        | **100%**      | [BNF file format](https://github.com/AlexKimov/RSE-file-formats/wiki/BNF-File-Format)           | Charater animation data |
| 3 | .chr        | [CHR.bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/CHR.bt)        | **100%**      | [CHR file format](https://github.com/AlexKimov/RSE-file-formats/wiki/CHR-File-Format)          | Character 3D model |
| 4 | .map        | [MAP(gr).bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/MAP(gr).bt)    | **80%** | [MAP file format](https://github.com/AlexKimov/RSE-file-formats/wiki/MAP-File-Format)          | Level: 3d Data, portals, lights, objects |
| 5 | .pob       | [POB.bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/POB.bt)        | **95%**      | [POB file format](https://github.com/AlexKimov/RSE-file-formats/wiki/POB-File-Format)          | 3D objects: vehicles (tanks, bmps and so on), helicopters, boats + Particles |
| 6 | .qob       | [QOB(gr).bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/QOB(gr).bt)        | **100%**      | [QOB file format](https://github.com/AlexKimov/RSE-file-formats/wiki/QOB-File-Format)        | 3D objects: Weapons + special objects. |
| 7 | .rsb       | [RSB.bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/RSB.bt)        | [**95%**](https://github.com/AlexKimov/RSE-file-formats/issues?q=is%3Aissue+is%3Aopen+label%3AGRoriginal)      | [RSB file format](https://github.com/AlexKimov/RSE-file-formats/wiki/RSB-File-Format)          | Texture |

**2. RainBow Six**

| № | Format       | Template name     | Progress     | Specs | Description |
| :--- | :--------- | :----------- | :---------- | :---------- | :---------- |
| 1 | .crp        | [CRP(rs).bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/CRP(rs).bt)        | **99%**      |           | Character 3D model |
| 2 | .dam        | [DAM(rs).bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/DAM(rs).bt)        | **99%**      |          | Character animation data |
| 3 | .map       | [MAP(rs).bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/MAP(rs).bt)    | **70%**  |           | level |
| 4 | .skl       | [SKL(rs).bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/SKL(rs).bt)         | **99%**     |           | Skeleton |
| 5 | .rsb       | [RSB.bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/RSB.bt)        | [**100%**](https://github.com/AlexKimov/RSE-file-formats/issues?q=is%3Aissue+is%3Aopen+label%3AGRoriginal)      | [RSB file format](https://github.com/AlexKimov/RSE-file-formats/wiki/RSB-File-Format)          | Texture |
| 6 | .sob       | [SOB.bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/SOB.bt)        | **99%**      |          | Static 3D objects |

**3. Rainbow Six Rogue Spear**

| № | Format       | Template name     | Progress     | Specs | Description |
| :--- | :--------- | :----------- | :---------- | :---------- | :---------- |
| 1 | .crp        | [CRP(rsp).bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/CRP(rsp).bt)    | **90%**      |           | Character 3D model |
| 2 | .dam        | [DAM(rsp).bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/DAM(rsp).bt)        | **90%**      |          | Character animation data |
| 3 | .dmp        | [DMP.bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/DMP.bt)        | **80%**      |          | Level light |
| 4 | .map       | [MAP(rsp).bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/MAP(rsp).bt)   | **70%** |           | Level |
| 5 | .qob       | [QOB(rsp).bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/QOB(rsp).bt)        | **95%**      |      | 3D objects |
| 6 | .rob       | [ROB.bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/ROB.bt)        | **70%**      |           | 3D objects |
| 7 | .rsb       | [RSB.bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/RSB.bt)        | [**100%**](https://github.com/AlexKimov/RSE-file-formats/issues?q=is%3Aissue+is%3Aopen+label%3AGRoriginal)      | [RSB file format](https://github.com/AlexKimov/RSE-file-formats/wiki/RSB-File-Format)          | Texture |
| 8 | .skl       | [SKL(RSP).bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/SKL(RSP).bt)         | **99%**     |           | Skeleton |
| 9 | .sob       | [SOB(rsp).bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/SOB(rsp).bt) | **90%**    |           | Static 3D objects |

**3. Rainbow Six Lockdown**

| № | Format       | Template name     | Progress     | Specs | Description |
| :---: | :---------: | :-----------: | :----------: | :----------: | :----------: |
| 1 | .chr        | [CHR(LD).bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/CHR(ld).bt)        | **55%**      |           | 3D model |
| 2 | .qob       | [QOB(LD).bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/QOB(LD).bt)        | **65%**      |      | 3D object |
| 3 | .rsb       | [RSB.bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/RSB.bt)        | [**95%**](https://github.com/AlexKimov/RSE-file-formats/issues?q=is%3Aissue+is%3Aopen+label%3AGRoriginal)      | [RSB file format](https://github.com/AlexKimov/RSE-file-formats/wiki/RSB-File-Format)          | Texture |
| 4 | .skl       | [SKL(LD).bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/SKL(LD).bt)         | **50%**     |           | Skeleton |

**4. Dominant Species** 

| № | Format       | Template name     | Progress     | Specs | Description |
| :---: | :---------: | :-----------: | :----------: | :----------: | :----------: |
| 1 | .cmf        | [CMF.bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/CMF.bt)        | **50%**      |           | Character 3D model |
| 2 | .crp        | [CRP(ds).bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/CRP(ds).bt)    | **70%**      |           | character 3D model |
| 3 | .dam        | [DAM(ds).bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/DAM(ds).bt)        | **10%**      |          | Character animation data |


**5. Force 21**

| № | Format       | Template name     | Progress     | Specs | Description |
| :---: | :---------: | :-----------: | :----------: | :----------: | :----------: |
| 1  | .kit        | [KIT.bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/KIT.bt)        | **50%**     |          |   3D Model                         |
| 2 | .rsb       | [RSB.bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/RSB.bt)        | [**95%**](https://github.com/AlexKimov/RSE-file-formats/issues?q=is%3Aissue+is%3Aopen+label%3AGRoriginal)      | [RSB file format](https://github.com/AlexKimov/RSE-file-formats/wiki/RSB-File-Format)          | Texture |

**6. Freedom First Resistance**

| № | Format       | Template name     | Progress     | Specs | Description |
| :---: | :---------: | :-----------: | :----------: | :----------: | :----------: |
| 1 | .dam       | [DAM(rsp).bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/DAM(rsp).bt)   | **90%** |           | Character animations |
| 2 | .map       | [MAP(ffs).bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/MAP(ffs).bt)   | **70%** |           | level |
| 3 | .noz       | [NOZ.bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/NOZ.bt)   | **90%** |           | character model |
| 4 | .qob       | [QOB(ffs).bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/QOB(ffs).bt)        | **95%**      |      | 3D objects |
| 5 | .rsa       | [RSA.bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/RSA.bt)        | **100%**      |           | game archive |   
| 6 | .rsb       | [RSB.bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/RSB.bt)        | [**95%**](https://github.com/AlexKimov/RSE-file-formats/issues?q=is%3Aissue+is%3Aopen+label%3AGRoriginal)      | [RSB file format](https://github.com/AlexKimov/RSE-file-formats/wiki/RSB-File-Format)          | Texture |

**7. Shadow Watch**

| № | Format       | Template name     | Progress     | Specs | Description |
| :---: | :---------: | :-----------: | :----------: | :----------: | :----------: |
| 1 | .r16       | [R16.bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/R16.bt)        | **90%**      |           |Texture file |
| 2 | .smf       | [SMF.bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/SMF.bt)        | **99%**      |           | game archive |

**8. Ghost Recon 2**

| № | Format       | Template name     | Progress     | Specs | Description |
| :---: | :---------: | :-----------: | :----------: | :----------: | :----------: |
| 1 | .xpr       | [XPR.bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/XPR.bt)       | **75%**       |           | Texture file |

**9. Ghost Recon (playstaion)**

| № | Format       | Template name     | Progress     | Specs | Description |
| :---: | :---------: | :-----------: | :----------: | :----------: | :----------: |
| 1 | .rsb       | [RSB(ps2).bt](https://github.com/AlexKimov/RSE-file-formats/blob/master/010Editor-templates/RSB(ps2).bt)  | **5%**   |           | Texture file |

### Scripts

#### 010Editor
* [RSBtoBMP.1sc](https://github.com/AlexKimov/RSE-file-formats/blob/master/scripts/RSBtoBMP.1sc) - convert **RSB**, **R16**, **XPR** to **BMP** and **DDS** (files with DXT compression). Supported games: Rainbow six (1998), Rogue Spear (1999 - 2001), Ghost Recon (2001 - 2003), Sum Of All Fears (2002), Rainbow 6 LockDown (2005), partly Ghost Recon 2 XBOX (2004)
* [SOBtoObj.1sc](https://github.com/AlexKimov/RSE-file-formats/blob/master/scripts/SOBtoObj.1sc) - convert **SOB** (Rainbow six) to **Obj**
* [QOBtoObj.1sc](https://github.com/AlexKimov/RSE-file-formats/blob/master/scripts/QOBtoObj.1sc) - convert **QOB** (Ghost Recon) to **Obj**
* [CHRtoObj.1sc](https://github.com/AlexKimov/RSE-file-formats/blob/master/scripts/CHRtoObj.1sc) - convert **CHR** (Ghost Recon) to **Obj**
* [UnpackSMF.1sc](https://github.com/AlexKimov/RSE-file-formats/blob/master/scripts/UnpackSMF.1sc) - unpack **SMF** archive (Shadow Watch)
* [UnpackRSA.1sc](https://github.com/AlexKimov/RSE-file-formats/blob/master/scripts/UnpackRSA.1sc) - unpack **RSA** archive (Freedom First Resistance)

#### Noesis
* [fmt_rse_rsb.py](https://github.com/AlexKimov/RSE-file-formats/blob/master/scripts/noesis/fmt_rse_rsb.py) - open .rsb files

