*&---------------------------------------------------------------------*
*&  Include           ZGECAI_UTLTY_VRSN_CMRSN_FORMS
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  f_help_on_value_request
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_MINTAB  text
*      -->P_V_DNAM  text
*      -->P_V_FNAM  text
*----------------------------------------------------------------------*
FORM f_help_on_value_request TABLES   pt_tab
                             USING    pv_fld
                                      pv_fnam
                                      pv_title.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = pv_fnam
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = pv_fld
      window_title    = pv_title
      value_org       = 'S'
    TABLES
      value_tab       = pt_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " f_help_on_value_request
*&---------------------------------------------------------------------*
*&      Form  f_directory_browse
*&---------------------------------------------------------------------*
FORM f_directory_browse.
  DATA: lv_title     TYPE string,
        lv_filename  TYPE string,
        lv_path      TYPE string,
        lv_fullpath  TYPE string.

  DATA: lv_default_filename TYPE string.

  CONSTANTS: gc_default       TYPE string VALUE 'XLS',
             gc_filter        TYPE string VALUE 'Excel(*.XLS)|*.XLS|',
             gc_dir           TYPE string VALUE 'C:\'.

  lv_title = 'Save As'(005).
  lv_default_filename = text-019.

  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      window_title         = lv_title
      default_extension    = gc_default
      default_file_name    = lv_default_filename
      file_filter          = gc_filter
      initial_directory    = gc_dir
      prompt_on_overwrite  = 'X'
    CHANGING
      filename             = lv_filename
      path                 = lv_path
      fullpath             = lv_fullpath
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.

  IF lv_fullpath IS NOT INITIAL.
    PERFORM f_validate_file_extension USING lv_fullpath.
    gv_path = lv_fullpath.
  ELSE.
    RETURN.
  ENDIF.

ENDFORM.                    "f_directory_browse
*&---------------------------------------------------------------------*
*&      Form  f_directory_browse
*&---------------------------------------------------------------------*
FORM f_validate_file_extension USING pv_path.

  "File type validation
  gv_fpath_len = STRLEN( pv_path ).
  IF gv_fpath_len > 3.
    gv_fpath_len = gv_fpath_len - 3.
    IF pv_path+gv_fpath_len(3) <> 'xls' AND pv_path+gv_fpath_len(3) <> 'XLS'.
      MESSAGE 'Please select the correct file format (.XLS)'(006) TYPE 'E'.
    ENDIF.
  ELSE.
    MESSAGE 'Please select the correct file format (.XLS)'(006) TYPE 'E'.
  ENDIF.

ENDFORM.      "F_VALIDATE_FILE_EXTENSION
*&---------------------------------------------------------------------*
*&      Form  F_POP_OUTPUT_TBL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_pop_output_tbl.

  PERFORM f_combine_system1 USING gt_vsmg_tr gt_dev_tr.

  IF p_dest IS NOT INITIAL.
    PERFORM f_combine_system2 USING gt_vsmg_tr2 gt_dev_tr2.
  ENDIF.

  DESCRIBE TABLE gt_output LINES gv_total.

ENDFORM.                    " F_POP_OUTPUT_TBL
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_create_header .

  CLEAR gwa_head.REFRESH gt_head.

  gwa_head-col1 = text-007.
  gwa_head-col2 = text-008.
  gwa_head-col3 = text-009.
  gwa_head-col4 = text-010.
  gwa_head-col5 = text-011.
  gwa_head-col6 = text-012.
  gwa_head-col7 = text-010.
  gwa_head-col8 = text-011.

  IF p_dest IS NOT INITIAL.
    gwa_head-col10 = text-007.
    gwa_head-col11 = text-008.
    gwa_head-col12 = text-009.
    gwa_head-col13 = text-010.
    gwa_head-col14 = text-011.
    gwa_head-col15 = text-012.
    gwa_head-col16 = text-010.
    gwa_head-col17 = text-011.
  ENDIF.

  APPEND gwa_head TO gt_head.

ENDFORM.                    " F_CREATE_HEADER
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_display_alv .

  "Create the container
  IF go_alv_cont1 IS NOT INITIAL.
    EXIT.
  ENDIF.
  CREATE OBJECT go_alv_cont1
    EXPORTING
      container_name = gc_container.

* Create TOP-Document
  CREATE OBJECT go_dyndoc_id
    EXPORTING
      style = 'ALV_GRID'.

* Create Splitter for custom_container
  CREATE OBJECT go_splitter
    EXPORTING
      parent  = go_alv_cont1
      rows    = 2
      columns = 1.

* Split the custom_container to two containers and move the reference
* to receiving containers g_parent_html and g_parent_grid
  "Allocating the space for grid and top of page
  CALL METHOD go_splitter->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_parent_html.

  CALL METHOD go_splitter->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = go_parent_grid.

  CALL METHOD go_splitter->set_row_height
    EXPORTING
      id     = 1
      height = 20.

  CREATE OBJECT go_alv_out1
    EXPORTING
      i_parent = go_parent_grid.

  CALL METHOD go_alv_out1->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

  CREATE OBJECT g_handler.
  SET HANDLER g_handler->handle_top_of_page FOR go_alv_out1.

  TRY .
    go_alv_out1->register_edit_event(
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified
      EXCEPTIONS
        error      = 1
        OTHERS     = 2
           ).
  ENDTRY.

  CALL METHOD cl_gui_control=>set_focus
    EXPORTING
      control = go_alv_out1.

  PERFORM f_set_layout.
  PERFORM f_auto_get_fieldcat TABLES  gt_output
                               USING 'GT_OUTPUT'.

  CALL METHOD go_alv_out1->set_table_for_first_display
    EXPORTING
      is_layout       = gwa_lvc_layout
    CHANGING
      it_fieldcatalog = gt_fieldcat
      it_outtab       = gt_output.

  CALL METHOD go_dyndoc_id->initialize_document.

  CALL METHOD go_alv_out1->list_processing_events
    EXPORTING
      i_event_name = 'TOP_OF_PAGE'
      i_dyndoc_id  = go_dyndoc_id.

  PERFORM f_refresh_alv USING go_alv_out1 gwa_lvc_layout.

ENDFORM.                    " F_DISPLAY_ALV
*&---------------------------------------------------------------------*
*&      Form  f_refresh_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

FORM f_refresh_alv USING po_alv TYPE REF TO cl_gui_alv_grid
                         pwa_layout TYPE lvc_s_layo.
  DATA lwa_stable TYPE lvc_s_stbl.

  lwa_stable-row = abap_true.
  lwa_stable-col = abap_true.

  CALL METHOD po_alv->set_frontend_layout
    EXPORTING
      is_layout = pwa_layout.
  po_alv->refresh_table_display(
    EXPORTING
       is_stable      = lwa_stable
     EXCEPTIONS
       finished       = 1
       OTHERS         = 2
          ).
ENDFORM.                    "f_refresh_alv
*&---------------------------------------------------------------------*
*&      Form  f_event_top_of_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->go_DYNDOC_ID  text
*----------------------------------------------------------------------*
FORM f_event_top_of_page USING go_dyndoc_id TYPE REF TO cl_dd_document.

  DATA: dl_text(255) TYPE c.  "Text
  DATA: lv_rundate   TYPE char15.
  DATA: lv_runtime   TYPE char15.

* Populating header to top-of-page
  CALL METHOD go_dyndoc_id->add_text
    EXPORTING
      text      = 'Version Comparison Utility'(020)
      sap_style = cl_dd_area=>heading.

  CALL METHOD go_dyndoc_id->new_line.
  CALL METHOD go_dyndoc_id->new_line.
  CLEAR : dl_text.
  PERFORM f_bold_title USING 'Program ID :'(014).
  PERFORM f_add_gap USING 10.
  dl_text = sy-repid.
  PERFORM f_add_text USING dl_text.
  CALL METHOD go_dyndoc_id->new_line.

  CLEAR : dl_text.
  PERFORM f_bold_title USING 'Run Date :'(015).
  PERFORM f_add_gap USING 13.
  WRITE sy-datum TO lv_rundate.
  dl_text = lv_rundate.
  PERFORM f_add_text USING dl_text.
  PERFORM f_add_gap USING 8.
  PERFORM f_bold_title USING 'Run Time :'(016).
  PERFORM f_add_gap USING 19.
  WRITE sy-uzeit TO lv_runtime.
  dl_text = lv_runtime.
  PERFORM f_add_text USING dl_text.
  CALL METHOD go_dyndoc_id->new_line.

  CLEAR : dl_text.
  PERFORM f_bold_title USING 'Printed by :'(017).
  PERFORM f_add_gap USING 11.
  dl_text = sy-uname.
  PERFORM f_add_text USING dl_text.
  CALL METHOD go_dyndoc_id->new_line.

  CLEAR : dl_text.
  PERFORM f_bold_title USING 'Total Records :'(018).
  PERFORM f_add_gap USING 6.
  dl_text = gv_total.
  PERFORM f_add_text USING dl_text.
  CALL METHOD go_dyndoc_id->new_line.

* Populating data to html control
  PERFORM f_html.

ENDFORM.                    " F_EVENT_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*&      Form  f_add_gap
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PV_GAP     text
*----------------------------------------------------------------------*
FORM f_add_gap USING pv_gap.
  CALL METHOD go_dyndoc_id->add_gap
    EXPORTING
      width = pv_gap.
ENDFORM.                    "f_add_gap
*&---------------------------------------------------------------------*
*&      Form  f_bold_title
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PV_TITLE   text
*----------------------------------------------------------------------*
FORM f_bold_title USING pv_title.

  CALL METHOD go_dyndoc_id->add_text
    EXPORTING
      text         = pv_title
      sap_emphasis = cl_dd_document=>strong.

ENDFORM.                    "f_bold_title
*&---------------------------------------------------------------------*
*&      Form  F_ADD_TEXT
*&---------------------------------------------------------------------*
*       To add Text
*----------------------------------------------------------------------*
FORM f_add_text USING p_text TYPE sdydo_text_element.
* Adding text
  CALL METHOD go_dyndoc_id->add_text
    EXPORTING
      text         = p_text
      sap_emphasis = cl_dd_area=>heading.
ENDFORM.                    " F_ADD_TEXT

*&---------------------------------------------------------------------*
*&      Form  f_html
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_html.
  DATA : dl_background_id TYPE sdydo_key VALUE space. " Background_id

* Creating html control
  IF go_html_cntrl IS INITIAL.
    CREATE OBJECT go_html_cntrl
      EXPORTING
        parent = go_parent_html.
  ENDIF.

* Reuse_alv_grid_commentary_set
  CALL FUNCTION 'REUSE_ALV_GRID_COMMENTARY_SET'
    EXPORTING
      document = go_dyndoc_id
      bottom   = space.

* Get TOP->HTML_TABLE ready
  CALL METHOD go_dyndoc_id->merge_document.

* Set wallpaper
  CALL METHOD go_dyndoc_id->set_document_background
    EXPORTING
      picture_id = dl_background_id.

* Connect TOP document to HTML-Control
  go_dyndoc_id->html_control = go_html_cntrl.

* Display TOP document
  CALL METHOD go_dyndoc_id->display_document
    EXPORTING
      reuse_control = 'X'
      parent        = go_parent_html.

ENDFORM.                    " F_HTML
*&---------------------------------------------------------------------*
*&      Form  F_SET_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_set_layout .

  gwa_lvc_layout-cwidth_opt = abap_true.
  gwa_lvc_layout-keyhot = abap_true.
  gwa_lvc_layout-stylefname = 'CELLTAB'.
  gwa_lvc_layout-info_fname  = 'COLOR'.

ENDFORM.                    " F_SET_LAYOUT
*&---------------------------------------------------------------------*
*&      Form  F_AUTO_GET_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM f_auto_get_fieldcat    TABLES   tt_data
                            USING    pv_alv_tab_name TYPE string.

  DATA lo_tab_desc TYPE REF TO cl_abap_structdescr.
  DATA lt_struc_comp TYPE abap_component_tab.
  DATA ls_struc_comp TYPE LINE OF abap_component_tab.

  CLEAR gt_fieldcat[].

  lo_tab_desc ?= cl_abap_tabledescr=>describe_by_data( tt_data ).

  lt_struc_comp = lo_tab_desc->get_components( ).

  LOOP AT lt_struc_comp INTO ls_struc_comp.
    "Get field name and tab name.
    gwa_fieldcat-fieldname = ls_struc_comp-name.
    gwa_fieldcat-tabname = pv_alv_tab_name.
    gwa_fieldcat-seltext   = ls_struc_comp-name.
    gwa_fieldcat-outputlen = 15.
    gwa_fieldcat-col_opt   = 'X'.

    APPEND gwa_fieldcat TO gt_fieldcat.
    CLEAR gwa_fieldcat.

  ENDLOOP.

  IF p_dest IS INITIAL.
    PERFORM f_change_text USING: 'OBJ_NAME' text-007,
                                 'OBJECT'   text-008,
                                 'TR_DEV'   text-009,
                                 'DATE'     text-010,
                                 'TIME'     text-011,
                                 'TR_VSMG'  text-012,
                                 'DATUM'    text-010,
                                 'ZEIT'     text-011.

    PERFORM f_hide_field USING: 'STATUS',
                                'OBJ_NAME2',
                                'OBJECT2',
                                'TR_DEV2',
                                'DATE2',
                                'TIME2',
                                'TR_VSMG2',
                                'DATUM2',
                                'ZEIT2'.
  ELSE.
    PERFORM f_change_text USING: 'OBJ_NAME'  text-022,
                                 'OBJECT'    text-023,
                                 'TR_DEV'    text-024,
                                 'DATE'      text-025,
                                 'TIME'      text-026,
                                 'TR_VSMG'   text-027,
                                 'DATUM'     text-025,
                                 'ZEIT'      text-026,
                                 'STATUS'    text-028,
                                 'OBJ_NAME2' text-029,
                                 'OBJECT2'   text-030,
                                 'TR_DEV2'   text-031,
                                 'DATE2'     text-032,
                                 'TIME2'     text-033,
                                 'TR_VSMG2'  text-034,
                                 'DATUM2'    text-032,
                                 'ZEIT2'     text-033.
  ENDIF.


ENDFORM.                    " F_AUTO_GET_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM f_change_text USING pv_fname pv_text.

  FIELD-SYMBOLS: <lfs_fcat> TYPE lvc_s_fcat.

  READ TABLE gt_fieldcat ASSIGNING <lfs_fcat>
       WITH KEY fieldname = pv_fname.
  IF sy-subrc = 0.
    <lfs_fcat>-seltext = pv_text.
    <lfs_fcat>-coltext = pv_text.
  ENDIF.
ENDFORM.                    " F_CHANGE_TEXT
*&---------------------------------------------------------------------*
*&      Form  F_HIDE_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PV_fieldname   text
*----------------------------------------------------------------------*
FORM f_hide_field  USING pv_fieldname.

  FIELD-SYMBOLS: <lfs_fcat> TYPE lvc_s_fcat.

  READ TABLE gt_fieldcat ASSIGNING <lfs_fcat> WITH KEY fieldname = pv_fieldname.
  IF sy-subrc EQ 0.
    <lfs_fcat>-tech = 'X'.
  ENDIF.

ENDFORM.                    " F_HIDE_FIELD
*&---------------------------------------------------------------------*
*&      Module  M_STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_status_9000 OUTPUT.

  SET PF-STATUS 'PF9000'.
  PERFORM f_display_alv.

ENDMODULE.                 " M_STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  M_USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_user_command_9000 INPUT.

  CASE sy-ucomm.
    WHEN '&F15' OR '&F12' OR '&F03'.
      LEAVE TO SCREEN 0.
    WHEN '&EXCEL'.
      PERFORM f_directory_browse.
      "Populate gt_head for excel table headers
      PERFORM f_create_header.
      "Download results to Excel
      PERFORM f_output_excel USING gt_head gt_output gv_path.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " M_USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*&      Form  F_COMBINE_SYSTEM1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PIT_VSMG_TR  text
*      -->PIT_DEV_TR  text
*----------------------------------------------------------------------*
FORM f_combine_system1  USING    pit_vsmg_tr LIKE gt_vsmg_tr
                                 pit_dev_tr LIKE gt_dev_tr.

  FIELD-SYMBOLS <lfs_vsmg_tr> TYPE zgecas_vsmg_tr.
  FIELD-SYMBOLS <lfs_dev_tr>  TYPE zgecas_dev_tr.

  "Combine results into output table
  LOOP AT pit_vsmg_tr ASSIGNING <lfs_vsmg_tr>.
    CLEAR gwa_output.
    gwa_output-obj_name = <lfs_vsmg_tr>-obj_name.
    gwa_output-object   = <lfs_vsmg_tr>-object.
    gwa_output-tr_vsmg  = <lfs_vsmg_tr>-tr_vsmg.
    IF <lfs_vsmg_tr>-datum IS NOT INITIAL.
      gwa_output-datum    = <lfs_vsmg_tr>-datum.
    ENDIF.
    IF <lfs_vsmg_tr>-zeit IS NOT INITIAL.
      gwa_output-zeit     = <lfs_vsmg_tr>-zeit.
    ENDIF.

    READ TABLE pit_dev_tr ASSIGNING <lfs_dev_tr> WITH KEY obj_name = <lfs_vsmg_tr>-obj_name object = <lfs_vsmg_tr>-object.
    IF sy-subrc EQ 0.
      gwa_output-tr_dev = <lfs_dev_tr>-tr_dev.
      IF <lfs_dev_tr>-datum IS NOT INITIAL.
        gwa_output-date   = <lfs_dev_tr>-datum.
      ENDIF.
      IF <lfs_dev_tr>-zeit IS NOT INITIAL.
        gwa_output-time   = <lfs_dev_tr>-zeit.
      ENDIF.
    ENDIF.
    APPEND gwa_output TO gt_output.
  ENDLOOP.

  "QC/FDR system (gt_vsmg_tr will always be empty)
  IF sy-subrc NE 0.
    LOOP AT pit_dev_tr ASSIGNING <lfs_dev_tr>.
      CLEAR gwa_output.
      gwa_output-obj_name = <lfs_dev_tr>-obj_name.
      gwa_output-object   = <lfs_dev_tr>-object.
      gwa_output-tr_dev   = <lfs_dev_tr>-tr_dev.
      IF <lfs_dev_tr>-datum IS NOT INITIAL.
        gwa_output-date     = <lfs_dev_tr>-datum.
      ENDIF.
      IF <lfs_dev_tr>-zeit IS NOT INITIAL.
        gwa_output-time     = <lfs_dev_tr>-zeit.
      ENDIF.
      APPEND gwa_output TO gt_output.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " F_COMBINE_SYSTEM1
*&---------------------------------------------------------------------*
*&      Form  F_COMBINE_SYSTEM2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PIT_VSMG_TR2  text
*      -->PIT_DEV_TR2  text
*----------------------------------------------------------------------*
FORM f_combine_system2  USING    pit_vsmg_tr2 LIKE gt_vsmg_tr2
                                 pit_dev_tr2 LIKE gt_dev_tr2.

  FIELD-SYMBOLS <lfs_vsmg_tr> TYPE zgecas_vsmg_tr.
  FIELD-SYMBOLS <lfs_dev_tr>  TYPE zgecas_dev_tr.
  FIELD-SYMBOLS <lfs_output>  TYPE gty_output.

  "Combine results into output table
  LOOP AT pit_vsmg_tr2 ASSIGNING <lfs_vsmg_tr>.
    "Add System 2 records parallel to system 1 records so that they can be sorted and compared
    READ TABLE gt_output ASSIGNING <lfs_output> WITH KEY obj_name = <lfs_vsmg_tr>-obj_name object = <lfs_vsmg_tr>-object.
    IF sy-subrc EQ 0.
      <lfs_output>-obj_name2 = <lfs_vsmg_tr>-obj_name.
      <lfs_output>-object2   = <lfs_vsmg_tr>-object.
      <lfs_output>-tr_vsmg2  = <lfs_vsmg_tr>-tr_vsmg.
      IF <lfs_vsmg_tr>-datum IS NOT INITIAL.
        <lfs_output>-datum2    = <lfs_vsmg_tr>-datum.
      ENDIF.
      IF <lfs_vsmg_tr>-zeit IS NOT INITIAL.
        <lfs_output>-zeit2     = <lfs_vsmg_tr>-zeit.
      ENDIF.

      READ TABLE pit_dev_tr2 ASSIGNING <lfs_dev_tr> WITH KEY obj_name = <lfs_vsmg_tr>-obj_name object = <lfs_vsmg_tr>-object.
      IF sy-subrc EQ 0.
        <lfs_output>-tr_dev2 = <lfs_dev_tr>-tr_dev.
        IF <lfs_dev_tr>-datum IS NOT INITIAL.
          <lfs_output>-date2   = <lfs_dev_tr>-datum.
        ENDIF.
        IF <lfs_dev_tr>-zeit IS NOT INITIAL.
          <lfs_output>-time2   = <lfs_dev_tr>-zeit.
        ENDIF.
      ENDIF.
    ELSE.
      "If system 2 object entries not found in system 1 then append
      CLEAR gwa_output.
      gwa_output-obj_name2 = <lfs_vsmg_tr>-obj_name.
      gwa_output-object2   = <lfs_vsmg_tr>-object.
      gwa_output-tr_vsmg2  = <lfs_vsmg_tr>-tr_vsmg.
      IF <lfs_vsmg_tr>-datum IS NOT INITIAL.
        gwa_output-datum2    = <lfs_vsmg_tr>-datum.
      ENDIF.
      IF <lfs_vsmg_tr>-zeit IS NOT INITIAL.
        gwa_output-zeit2     = <lfs_vsmg_tr>-zeit.
      ENDIF.

      READ TABLE pit_dev_tr2 ASSIGNING <lfs_dev_tr> WITH KEY obj_name = <lfs_vsmg_tr>-obj_name object = <lfs_vsmg_tr>-object.
      IF sy-subrc EQ 0.
        gwa_output-tr_dev2 = <lfs_dev_tr>-tr_dev.
        IF <lfs_dev_tr>-datum IS NOT INITIAL.
          gwa_output-date2   = <lfs_dev_tr>-datum.
        ENDIF.
        IF <lfs_dev_tr>-zeit IS NOT INITIAL.
          gwa_output-time2   = <lfs_dev_tr>-zeit.
        ENDIF.
      ENDIF.
      APPEND gwa_output TO gt_output.
    ENDIF.
  ENDLOOP.

  "QC/FDR system (gt_vsmg_tr will always be empty)
  IF sy-subrc NE 0.
    LOOP AT pit_dev_tr2 ASSIGNING <lfs_dev_tr>.
      "Add System 2 records parallel to system 1 records so that they can be sorted and compared
      READ TABLE gt_output ASSIGNING <lfs_output> WITH KEY obj_name = <lfs_dev_tr>-obj_name object = <lfs_dev_tr>-object.
      IF sy-subrc EQ 0.
        <lfs_output>-obj_name2 = <lfs_dev_tr>-obj_name.
        <lfs_output>-object2   = <lfs_dev_tr>-object.
        <lfs_output>-tr_dev2   = <lfs_dev_tr>-tr_dev.
        IF <lfs_dev_tr>-datum IS NOT INITIAL.
          <lfs_output>-date2     = <lfs_dev_tr>-datum.
        ENDIF.
        IF <lfs_dev_tr>-zeit IS NOT INITIAL.
          <lfs_output>-time2     = <lfs_dev_tr>-zeit.
        ENDIF.
      ELSE.
        CLEAR gwa_output.
        gwa_output-obj_name2 = <lfs_dev_tr>-obj_name.
        gwa_output-object2   = <lfs_dev_tr>-object.
        gwa_output-tr_dev2   = <lfs_dev_tr>-tr_dev.
        IF <lfs_dev_tr>-datum IS NOT INITIAL.
          gwa_output-date2     = <lfs_dev_tr>-datum.
        ENDIF.
        IF <lfs_dev_tr>-zeit IS NOT INITIAL.
          gwa_output-time2     = <lfs_dev_tr>-zeit.
        ENDIF.
        APPEND gwa_output TO gt_output.
      ENDIF.
    ENDLOOP.
  ENDIF.

  LOOP AT gt_output ASSIGNING <lfs_output>.
    "If Development Database TRs match across systems for same object - Status = Green
    IF <lfs_output>-obj_name EQ <lfs_output>-obj_name2
      AND <lfs_output>-object EQ <lfs_output>-object
        AND <lfs_output>-tr_dev EQ <lfs_output>-tr_dev2 .
      <lfs_output>-status = icon_green_light.
      "If Version Management Database TR in System 1 matches Development TR in System 2 - Status = Yellow
    ELSEIF <lfs_output>-obj_name EQ <lfs_output>-obj_name2
      AND <lfs_output>-object EQ <lfs_output>-object
        AND <lfs_output>-tr_vsmg EQ <lfs_output>-tr_dev2.
      <lfs_output>-status = icon_yellow_light.
      "If Development Database TR in System 2 is not matched in System 1 - Status = Red
    ELSEIF <lfs_output>-obj_name EQ <lfs_output>-obj_name2
      AND <lfs_output>-object EQ <lfs_output>-object.
      <lfs_output>-status = icon_red_light.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " F_COMBINE_SYSTEM2
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_TRS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_retrieve_trs .

  DATA: lr_pkg TYPE zgecat_r_pkg.

  lr_pkg[] = s_pkg[].

                                                            "System 1
  CALL FUNCTION 'ZGECAFN_UTILITY_RETRIEVE_TRS'
    EXPORTING
      iv_clas    = p_clas
      ir_pkg     = lr_pkg
    IMPORTING
      et_vsmg_tr = gt_vsmg_tr
      et_dev_tr  = gt_dev_tr.

                                                            "System 2
  IF p_dest IS NOT INITIAL.

    CALL FUNCTION 'FUNCTION_EXISTS' DESTINATION p_dest
      EXPORTING
        funcname           = 'ZGECAFN_UTILITY_RETRIEVE_TRS'
      EXCEPTIONS
        function_not_exist = 1
        OTHERS             = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.

    CALL FUNCTION 'ZGECAFN_UTILITY_RETRIEVE_TRS' DESTINATION p_dest
      EXPORTING
        iv_clas    = p_clas
        ir_pkg     = lr_pkg
      IMPORTING
        et_vsmg_tr = gt_vsmg_tr2
        et_dev_tr  = gt_dev_tr2.
  ENDIF.

ENDFORM.                    " F_RETRIEVE_TRS
*&---------------------------------------------------------------------*
*&      Form  F_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init .

  PERFORM f_variant_init.

  SELECT * FROM tbdlst INTO CORRESPONDING FIELDS OF TABLE gt_logsys.
  SORT gt_logsys BY logsys.

ENDFORM.                    " F_INIT
*&---------------------------------------------------------------------*
*&      Form  f_variant_init
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_variant_init.
  CLEAR gwa_variant.
  gwa_variantx-report = gwa_variant-report = sy-repid.

  MOVE gwa_variant TO gwa_variantx.
  CALL FUNCTION 'LVC_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = 'A'
    CHANGING
      cs_variant = gwa_variantx
    EXCEPTIONS
      not_found  = 1.
  IF sy-subrc EQ 0.
    gwa_variant-variant = p_var = gwa_variantx-variant.
  ELSE.
    CLEAR gwa_variant.
  ENDIF.

ENDFORM.                    "f_variant_init
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_RFC_DEST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_check_rfc_dest USING p_dest.

  DATA: lv_rc TYPE sysubrc.

  CALL FUNCTION 'CAT_CHECK_RFC_DESTINATION'
    EXPORTING
      rfcdestination = p_dest
    IMPORTING
      rfc_subrc      = lv_rc.

  IF lv_rc NE 0.
    MESSAGE 'Invalid RFC Destination'(035) TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.                    " F_CHECK_RFC_DEST
