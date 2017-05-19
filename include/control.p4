/* Copyright 2013-present NetArch Lab, Tsinghua University.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


#ifndef HYPERVISOR_CONTROL
#define HYPERVISOR_CONTROL

#include "define.p4"

//-----------------------------------------------------
// Actions for control logic
//-----------------------------------------------------


//----------------- ingress ---------------------------
table table_config_at_initial {
	reads{		
		POLICY_ID : exact  ; 
		PROG_ID   : exact ;
		STAGE_ID  : exact ;
	}
	actions{
		action_set_initial_config;
	}
}

table table_config_at_end {
	reads{		
		POLICY_ID : exact  ; 
		PROG_ID   : exact ;
		STAGE_ID  : exact ;
	}
	actions{
		action_resubmit;
	}
}

//-----------------------------------------------------
action action_set_match_result (match_result){
	bit_or(MATCH_RESULT, match_result, MATCH_RESULT);
}

//-----------------------------------------------------
action action_set_action_id(match_result, action_bitmap,
                match_bitmap, next_stage, next_prog) {
	action_set_match_result(match_result);
	action_set_stage_and_bitmap(action_bitmap, 
        match_bitmap, next_stage, next_prog);
}

//-----------------------------------------------------
action action_set_next_stage(match_bitmap, next_stage, next_prog) {
	action_set_stage_and_bitmap(0, match_bitmap,
        next_stage, next_prog);
}

//-----------------------------------------------------
action action_end(next_prog) {
	action_set_action_id(0, 0, 0 , 0, next_prog);
}

//-----------------------------------------------------
action action_set_stage_and_bitmap (action_bitmap, 
                match_bitmap , next_stage, next_prog) {
	modify_field(ACTION_BITMAP, action_bitmap);
	modify_field(MATCH_BITMAP, match_bitmap);
	modify_field(STAGE_ID, next_stage);
	modify_field(PROGRAM_ID, next_prog);
	modify_field(ACTION_ID, MATCH_RESULT);
	modify_field(MATCH_RESULT, 0);
}

//-----------------------------------------------------
action action_set_action_id_direct (action_id, action_bitmap, 
                match_bitmap , next_stage, next_prog) {
	modify_field(ACTION_BITMAP, action_bitmap);
	modify_field(MATCH_BITMAP, match_bitmap);
	modify_field(STAGE_ID, next_stage);
	modify_field(PROGRAM_ID, next_prog);
	modify_field(ACTION_ID, action_id);
}

//-----------------------------------------------------
action action_set_match_result_with_next_stage (match_result, match_bitmap, next_stage) {
	modify_field(ACTION_BITMAP, 0);
	modify_field(MATCH_BITMAP, match_bitmap);
	modify_field(STAGE_ID, next_stage);
	modify_field(MATCH_RESULT, match_result);
}


//-----------------------------------------------------
action action_set_initial_config (progid, initstage, 
                                        match_bitmap) {
	modify_field(PROGRAM_ID , progid);
	modify_field(STAGE_ID, initstage);
	modify_field(MATCH_BITMAP, match_bitmap);
}

//----------------- Egress ----------------------------
table table_config_at_egress {
	reads{		
		POLICY_ID 	: exact ; 
		PROG_ID 	: exact ;
		STAGE_ID   	: exact ;
	}
	actions {
		action_recirculate;
	}
}

table dh_deparse {
	actions {
		action_dh_deparse;
	}
}

//-----------------------------------------------------
action action_dh_deparse() {
	modify_field(dhInstance.dh_load_header, LOAD_HEADER);
}


//--------------Conditional Stage----------------------

//-----------------------------------------------------
action action_set_expr_header_op_const(l_expr_offset, 
                            l_expr_mask, op, r_expr) {
	modify_field(pmiInstance.pmi_left_expr, 
        (LOAD_HEADER >> l_expr_offset)&l_expr_mask);
	modify_field(pmiInstance.pmi_op, op);
	modify_field(pmiInstance.pmi_right_expr, r_expr);
}


//-----------------------------------------------------
action action_set_expr_counter_op_const(op, r_expr) {
	modify_field(pmiInstance.pmi_left_expr, 
							pmiInstance.pmi_counter);
	modify_field(pmiInstance.pmi_op, op);
	modify_field(pmiInstance.pmi_right_expr, r_expr);
}

//-----------------------------------------------------
action action_set_expr_meta_op_const(l_expr_offset, 
                            l_expr_mask, op, r_expr) {
	modify_field(pmiInstance.pmi_left_expr, 
        (USER_META >> l_expr_offset)&l_expr_mask);
	modify_field(pmiInstance.pmi_op, op);
	modify_field(pmiInstance.pmi_right_expr, r_expr);
}

//-----------------------------------------------------
action action_set_expr_header_op_header(l_expr_offset, 
        l_expr_mask, op, r_expr_offset, r_expr_mask) {
	modify_field(pmiInstance.pmi_left_expr, 
        (LOAD_HEADER >> l_expr_offset) & l_expr_mask);
	modify_field(pmiInstance.pmi_op, op);
	modify_field(pmiInstance.pmi_left_expr, 
        (LOAD_HEADER >> r_expr_offset) & r_expr_mask);

}

//-----------------------------------------------------
action action_set_expr_meta_op_header(l_expr_offset, 
        l_expr_mask, op, r_expr_offset, r_expr_mask) {
	modify_field(pmiInstance.pmi_left_expr, 
        (USER_META >> l_expr_offset)&l_expr_mask);
	modify_field(pmiInstance.pmi_op, op);
	modify_field(pmiInstance.pmi_left_expr, 
        (LOAD_HEADER >> r_expr_offset) & r_expr_mask);
}

//-----------------------------------------------------
action action_set_expr_header_op_meta(l_expr_offset, 
        l_expr_mask, op, r_expr_offset, r_expr_mask) {
	modify_field(pmiInstance.pmi_left_expr, 
        (LOAD_HEADER >> l_expr_offset)&l_expr_mask);
	modify_field(pmiInstance.pmi_op, op);
	modify_field(pmiInstance.pmi_left_expr, 
        (USER_META >> r_expr_offset) & r_expr_mask);
}

//-----------------------------------------------------
action action_set_expr_meta_op_meta(l_expr_offset, 
        l_expr_mask, op, r_expr_offset, r_expr_mask) {
	modify_field(pmiInstance.pmi_left_expr, 
        (USER_META << l_expr_offset)&l_expr_mask);
	modify_field(pmiInstance.pmi_op, op);
	modify_field(pmiInstance.pmi_left_expr, 
        (USER_META << r_expr_offset) & r_expr_mask);
}

#endif
