*&---------------------------------------------------------------------*
*&  Include           ZGECAI_UTLTY_VRSN_CMRSN_TOP
*&---------------------------------------------------------------------*

TABLES: tadir, sscrfields.

TYPES: BEGIN OF gty_output,
          obj_name(110)  TYPE c,
          object         TYPE versobjtyp,
          tr_dev         TYPE trkorr,
          date           TYPE as4date,
          time           TYPE as4time,
          tr_vsmg        TYPE verskorrno,
          datum          TYPE versdate,
          zeit           TYPE verstime,
          status         TYPE zgelee_lightind,
          obj_name2(110) TYPE c,
          object2        TYPE versobjtyp,
          tr_dev2        TYPE trkorr,
          date2          TYPE as4date,
          time2          TYPE as4time,
          tr_vsmg2       TYPE verskorrno,
          datum2         TYPE versdate,
          zeit2          TYPE verstime,
      END OF gty_output.

TYPES: BEGIN OF gty_head,
          col1     TYPE string,
          col2     TYPE string,
          col3     TYPE string,
          col4     TYPE string,
          col5     TYPE string,
          col6     TYPE string,
          col7     TYPE string,
          col8     TYPE string,
          col9(1)  TYPE c,       "Output break
          col10    TYPE string,
          col11    TYPE string,
          col12    TYPE string,
          col13    TYPE string,
          col14    TYPE string,
          col15    TYPE string,
          col16    TYPE string,
          col17    TYPE string,
       END OF gty_head.

TYPES: BEGIN OF gty_logsys,
          logsys TYPE logsys,
          stext  TYPE text40,
       END OF gty_logsys.

DATA: gt_logsys    TYPE TABLE OF gty_logsys.
DATA: gt_vsmg_tr   TYPE zgecat_vsmg_tr.
DATA: gt_vsmg_tr2  TYPE zgecat_vsmg_tr.
DATA: gt_dev_tr    TYPE zgecat_dev_tr.
DATA: gt_dev_tr2   TYPE zgecat_dev_tr.
DATA: gt_output    TYPE TABLE OF gty_output.
DATA: gt_head      TYPE TABLE OF gty_head.
DATA: gv_fpath_len TYPE i.
DATA: gwa_output   TYPE gty_output.
DATA: gwa_head     TYPE gty_head.
DATA: gv_path      TYPE rlgrap-filename.

***ALV***

DATA: go_alv_cont1   TYPE REF TO cl_gui_custom_container.
DATA: go_alv_out1    TYPE REF TO cl_gui_alv_grid.
DATA: go_splitter    TYPE REF TO cl_gui_splitter_container.
DATA: go_parent_html TYPE REF TO cl_gui_container.
DATA: go_html_cntrl  TYPE REF TO cl_gui_html_viewer.
DATA: go_parent_grid TYPE REF TO cl_gui_container.
DATA: go_dyndoc_id   TYPE REF TO cl_dd_document.
DATA: gwa_lvc_layout TYPE lvc_s_layo.
DATA: gv_total       TYPE char40.
DATA: gt_fieldcat    TYPE lvc_t_fcat,
      gwa_fieldcat   TYPE lvc_s_fcat.
DATA: gwa_variant    TYPE disvariant,
      gwa_variantx   TYPE disvariant.
DATA: gv_exit        TYPE char01.

CONSTANTS: gc_container TYPE scrfname VALUE  'ALV_CONTAINER1'.
