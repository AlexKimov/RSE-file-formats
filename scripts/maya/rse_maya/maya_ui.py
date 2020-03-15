import maya.OpenMayaUI as omUI

try:
    from PySide2 import QtCore, QtGui, QtWidgets
    from shiboken2 import wrapInstance
except ImportError:
    from PySide import QtCore, QtGui
    from PySide import QtGui as QtWidgets
    from shiboken import wrapInstance


def get_mayamainwindow():
    pointer = omUI.MQtUtil.mainWindow()
    return wrapInstance(long(pointer), QtWidgets.QMainWindow)


class export_controls(QtWidgets.QWidget):
    def __init__(self, parent=None):
        super(export_controls, self).__init__(parent)

        self.parent = parent
        self.popup = None  # reference for popup widget

        self.create_controls()

    def create_controls(self):
        # create controls
        # materials
        self.list_materials = QtWidgets.QListWidget()
        self.btn_mat_create = QtWidgets.QPushButton('Create ...', self)
        self.btn_mat_edit = QtWidgets.QPushButton('Edit', self)
        self.btn_mat_delete = QtWidgets.QPushButton('Delete', self)
        self.btn_mat_refresh = QtWidgets.QPushButton('Refresh', self)
        # animations
        self.list_animations = QtWidgets.QListWidget()
        self.list_animations.setSelectionMode(QtWidgets.QAbstractItemView.ExtendedSelection)
        self.btn_anim_create = QtWidgets.QPushButton('Create ...', self)
        self.btn_anim_edit = QtWidgets.QPushButton('Edit', self)
        self.btn_anim_delete = QtWidgets.QPushButton('Delete', self)
        self.btn_anim_refresh = QtWidgets.QPushButton('Refresh', self)

        # TODO: re-enable these once supported
        self.btn_anim_create.setDisabled(True)
        self.btn_anim_edit.setDisabled(True)
        self.btn_anim_delete.setDisabled(True)
        self.btn_anim_refresh.setDisabled(True)

        # create layouts
        main_layout = QtWidgets.QHBoxLayout()
        main_layout.setSpacing(5)
        main_layout.setContentsMargins(5, 5, 5, 5)

        left_layout = QtWidgets.QVBoxLayout()
        left_layout.setSpacing(5)
        grp_mats = QtWidgets.QGroupBox('Materials 000')
        grp_mats_layout = QtWidgets.QVBoxLayout()
        grp_mats_layout.setContentsMargins(4, 4, 4, 4)
        grp_mats_button_layout = QtWidgets.QHBoxLayout()
        grp_anims = QtWidgets.QGroupBox('Animations')
        grp_anims_layout = QtWidgets.QVBoxLayout()
        grp_anims_layout.setContentsMargins(4, 4, 4, 4)
        grp_anims_button_layout = QtWidgets.QHBoxLayout()

        right_layout = QtWidgets.QVBoxLayout()
        right_layout.setSpacing(5)
        grp_scene = QtWidgets.QGroupBox('Scene setup')
        grp_scene_layout = QtWidgets.QGridLayout()
        grp_scene_layout.setColumnStretch(1, 1)
        grp_scene_layout.setColumnStretch(2, 2)
        grp_scene_layout.setContentsMargins(4, 4, 4, 4)
        grp_scene_layout.setVerticalSpacing(5)

        # add controls
        self.setLayout(main_layout)
        main_layout.addLayout(left_layout)
        main_layout.addLayout(right_layout)

        left_layout.addWidget(grp_mats)
        grp_mats.setLayout(grp_mats_layout)
        grp_mats_layout.addWidget(self.list_materials)
        grp_mats_layout.addLayout(grp_mats_button_layout)
        grp_mats_button_layout.addWidget(self.btn_mat_create)
        grp_mats_button_layout.addWidget(self.btn_mat_edit)
        grp_mats_button_layout.addWidget(self.btn_mat_delete)
        grp_mats_button_layout.addWidget(self.btn_mat_refresh)
        grp_mats_button_layout.setSpacing(3)

        left_layout.addWidget(grp_anims)
        grp_anims.setLayout(grp_anims_layout)
        grp_anims_layout.addWidget(self.list_animations)
        grp_anims_layout.addLayout(grp_anims_button_layout)
        grp_anims_button_layout.addWidget(self.btn_anim_create)
        grp_anims_button_layout.addWidget(self.btn_anim_edit)
        grp_anims_button_layout.addWidget(self.btn_anim_delete)
        grp_anims_button_layout.addWidget(self.btn_anim_refresh)
        grp_anims_button_layout.setSpacing(3)

        right_layout.addWidget(grp_scene)
        grp_scene.setLayout(grp_scene_layout)


class RSEmaya_ui(QtWidgets.QDialog):
    """
        Main tool window.
    """

    def __init__(self, parent=None):
        # parent to the Maya main window.
        if not parent:
            parent = get_mayamainwindow()

        super(RSEmaya_ui, self).__init__(parent)
        self.popup = None  # reference for popup widget
        self.create_ui()
        self.setStyleSheet(
            'QGroupBox {'
            'border: 1px solid;'
            'border-color: rgba(0, 0, 0, 64);'
            'border-radius: 4px;'
            'margin-top: 8px;'
            'padding: 5px 2px 2px 2px;'
            'background-color: rgb(78, 80, 82);'
            '}'
            'QGroupBox::title {'
            'subcontrol-origin: margin;'
            'subcontrol-position: top left;'
            'left: 10px;'
            '}'
        )

    def create_ui(self):
        # window properties
        self.setWindowTitle('RSE Maya Tools')
        self.setWindowFlags(QtCore.Qt.Window)
        if self.parent():
            parent_x = self.parent().x()
            parent_y = self.parent().y()
            self.setGeometry(parent_x + 60, parent_y + 220, self.width(), self.height())

        # populate window
        self.create_controls()
        self.refresh_gui()

    def create_controls(self):
        main_layout = QtWidgets.QVBoxLayout()
        main_layout.setContentsMargins(0, 0, 0, 0)
        self.setLayout(main_layout)

        # create all of the main controls
        self.export_ctrls = export_controls(parent=self)

        # create menubar and add widgets to main layout
        main_layout.addWidget(self.export_ctrls)

    def refresh_gui(self):
        # call any gui refresh functions here
        pass

    @QtCore.Slot()
    def do_import_mesh(self):
        last_dir = IO_PDX_SETTINGS.last_import_mesh or ''
        filepath, filefilter = QtWidgets.QFileDialog.getOpenFileName(
            self, caption='Select .mesh file', dir=last_dir, filter='PDX Mesh files (*.mesh)'
        )

        if filepath != '':
            filepath = os.path.abspath(filepath)
            if os.path.splitext(filepath)[1] == '.mesh':
                if self.popup:
                    self.popup.close()
                self.popup = import_popup(filepath, parent=self)
                self.popup.show()
                IO_PDX_SETTINGS.last_import_mesh = filepath
            else:
                reply = QtWidgets.QMessageBox.warning(
                    self, 'READ ERROR',
                    'Unable to read selected file. The filepath ... '
                    '\n\n\t{0}'
                    '\n ... is not a .mesh file!'.format(filepath),
                    QtWidgets.QMessageBox.Ok, defaultButton=QtWidgets.QMessageBox.Ok
                )
                if reply == QtWidgets.QMessageBox.Ok:
                    IO_PDX_LOG.info("Nothing to import.")


def main():
    pdx_tools = RSEmaya_ui()
    pdx_tools.show()

if __name__ == '__main__':
    main()