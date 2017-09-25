*&---------------------------------------------------------------------*
*& Report  ZGECAR_UTILITY_VRSN_CMPRSN
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
*======================================================================*
*  Program Name         : ZGECAR_UTILITY_VRSN_CMPRSN
*  Created By           : D_BAARK
*  Created On           : 15 Jul 2015
*  Functional Design ID : Utility Program to Compare Object Versions
*                         displays the latest TR version number in the Development Database
*                         and Version Management Database either for an individual system
*                         or across and RFC destination for comparing two systems.
*
*======================================================================*
REPORT zgecar_utility_vrsn_cmprsn.

INCLUDE zgecai_utlty_vrsn_cmrsn_top.
INCLUDE zgecai_utlty_vrsn_cmrsn_sel.
INCLUDE zgecai_utlty_vrsn_cmrsn_forms.
INCLUDE zgecai_utlty_vrsn_cmrsn_dwnld.

INITIALIZATION.
  PERFORM f_init.

AT SELECTION-SCREEN.

START-OF-SELECTION.
  IF p_dest IS NOT INITIAL.
    PERFORM f_check_rfc_dest USING p_dest.
  ENDIF.

END-OF-SELECTION.

  "Get all latest Version Management Database and Development Database TRs for selected objects
  PERFORM f_retrieve_trs.

  "Populate gt_output by combining Version Management Database and Development Database TRS from System 1 (and System2)
  PERFORM f_pop_output_tbl.

  IF NOT gt_output[] IS INITIAL.
    "Display results in alv grid
    CALL SCREEN 9000.
  ELSE.
    MESSAGE 'No objects found'(013) TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.
