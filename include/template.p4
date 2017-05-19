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

#ifndef HYPERVISOR_TEMPLATE
#define HYPERVISOR_TEMPLATE

#include "define.p4"

//---------------------------------------------------------------------------
#define STAGE(X)															\
control match_action_##X {		                                          	\
	if (pmiInstance.pmi_match_chain_bitmap & BIT_MASK_HEADER    != 0) {     \
		apply(table_header_match_##X);                                      \
	}                                                                       \
	if (pmiInstance.pmi_match_chain_bitmap & BIT_MASK_STD_META  != 0) {     \
		apply (table_std_meta_match_##X);                                   \
	}                                                                       \
	if (pmiInstance.pmi_match_chain_bitmap & BIT_MASK_USER_META != 0) {     \
		apply(table_user_meta_##X);                                         \
	}																		\
	if (MATCH_RESULT != 0) {												\
		apply(table_match_result_##X);										\
	}																		\
	if (ACTION_BITMAP != 0)	{												\
		execute_action_##X();												\
    }						                                                \
}                                                                           \
table table_header_match_##X {                                              \
	reads {                                                                 \
		pmiInstance.pmi_program_id : exact ;                                \
		pmiInstance.pmi_stage_id : exact ;                                  \
		umiInstance.umi_load_header : ternary ;                             \
	}                                                                       \
	actions { 																\
		action_set_match_result; 											\
		action_set_action_id;												\
		action_set_next_stage;												\
		action_set_action_id_direct;										\
		action_end;															\
		action_set_match_result_with_next_stage;							\
	}    									                                \
}                                                                           \
table table_std_meta_match_##X {                                            \
	reads{                                                                  \
		pmiInstance.pmi_program_id : exact ;                                \
		pmiInstance.pmi_stage_id : exact ;                                  \
		standard_metadata.ingress_port : ternary ;                          \
		standard_metadata.packet_length : ternary ;                         \
		standard_metadata.egress_spec : ternary ;                           \
		standard_metadata.egress_port : ternary ;                           \
		standard_metadata.egress_instance : ternary ;                       \
		standard_metadata.instance_type : ternary ;                         \
	}                                                                       \
	actions { 																\
		action_set_match_result; 											\
		action_set_action_id;												\
		action_set_next_stage;												\
		action_end;															\
		action_set_action_id_direct;										\
		action_set_match_result_with_next_stage;							\
	}									                                    \
}                                                                           \
table table_user_meta_##X {	                                                \
	reads {                             				                    \
		pmiInstance.pmi_program_id 		: exact ;       			        \
		pmiInstance.pmi_stage_id 		: exact ;                  			\
		umiInstance.umi_user_metadata 	: ternary;            				\
	}                                                       				\
	actions { 																\
		action_set_match_result;											\
		action_set_action_id; 												\
		action_set_action_id_direct;										\
		action_set_next_stage;												\
		action_set_match_result_with_next_stage;							\
		action_end;															\
	}                    													\
}                                                           				\
table table_match_result_##X {                                				\
	reads {																	\
		MATCH_RESULT 	: exact;         									\
	}                                                       				\
	actions {																\
		action_set_action_id_direct; 										\ 
		action_set_stage_and_bitmap; 										\
	}                														\
}                                                           				


//---------------------------------------------------------------------------
#define CONDITIONAL_STAGE(X)												\
control conditional_##X {		    										\
	apply(table_get_expression_##X);										\
	if (pmiInstance.pmi_left_expr < pmiInstance.pmi_right_expr) {			\
		apply(table_branch_1_##X);											\
	} 																		\
	else if(pmiInstance.pmi_left_expr > pmiInstance.pmi_right_expr) {		\
		apply(table_branch_2_##X);										    \	
	} 																		\
	else {																	\
		apply(table_branch_3_##X);											\
	}																		\
}																			\
table table_get_expression_##X {											\
	reads {																	\
		pmiInstance.pmi_program_id : exact ;								\
		pmiInstance.pmi_stage_id : exact ;									\
	}																		\
	actions {																\
		action_set_expr_header_op_const;									\
		action_set_expr_header_op_header;									\
		action_set_expr_header_op_meta;										\
		action_set_expr_meta_op_const;										\
		action_set_expr_meta_op_header;										\
		action_set_expr_meta_op_meta;										\
		action_set_expr_counter_op_const;									\
	}																		\
}																			\
table table_branch_1_##X {													\
	reads {																	\
		pmiInstance.pmi_program_id : exact ;								\
		pmiInstance.pmi_stage_id : exact ;									\
		pmiInstance.pmi_op : exact;											\
	}																		\
	actions { 																\
		action_set_next_stage; 												\
		action_set_match_result;											\
		action_set_action_id; 												\
		action_set_next_stage;												\
		action_end;															\
	}																		\
}																			\
table table_branch_2_##X {													\
	reads {																	\
		pmiInstance.pmi_program_id : exact ;								\
		pmiInstance.pmi_stage_id : exact ;									\
		pmiInstance.pmi_op : exact;											\
	}																		\
	actions { 																\
		action_set_next_stage;												\
		action_set_match_result;											\
		action_set_action_id; 												\
		action_set_next_stage;												\
		action_end;															\
	}																		\
}																			\
table table_branch_3_##X {													\
	reads {																	\
		pmiInstance.pmi_program_id : exact ;								\
		pmiInstance.pmi_stage_id : exact ;									\
		pmiInstance.pmi_op : exact;											\
	}																		\
	actions { 																\
		action_set_next_stage;												\
		action_set_match_result;											\
		action_set_action_id; 												\
		action_set_next_stage;												\
		action_end;															\
	}																		\
}																			


//-----------------------------------------------------------------------
#define EXECUTE_ACTION(X)												\
control execute_action_##X {											\
	if ((ACTION_BITMAP & BIT_MASK_MOD_HEADER_WITH_META) != 0) {			\
		apply(table_mod_header_with_meta_##X);							\
	}																	\
	if ((ACTION_BITMAP & BIT_MASK_MOD_META_WITH_META) != 0) {			\
		apply(table_mod_meta_with_meta_##X);							\
	}																	\
	if ((ACTION_BITMAP & BIT_MASK_MOD_HEADER_WITH_HEADER) != 0) {		\
		apply(table_mod_header_with_header_##X);						\
	}																	\
	if ((ACTION_BITMAP & BIT_MASK_MOD_META_WITH_HEADER) != 0) {			\
		apply(table_mod_meta_with_header_##X);							\
	}																	\
	if ((ACTION_BITMAP & BIT_MASK_MOD_HEADER_WITH_CONST) != 0) {		\
		apply(table_mod_header_with_const_##X);							\
	}																	\
	if ((ACTION_BITMAP & BIT_MASK_MOD_META_WITH_CONST) != 0) {			\
		apply(table_mod_meta_with_const_##X);							\
	}																	\
	if ((ACTION_BITMAP & BIT_MASK_ADD_HEDAER) != 0) {					\
		apply(table_add_header_##X);									\
	}																	\
	if ((ACTION_BITMAP & BIT_MASK_REMOVE_HEADER) != 0) {				\
		apply(table_remove_header_##X);									\
	}																	\
	if ((ACTION_BITMAP & BIT_MASK_MOD_STD_META) != 0) {					\
		apply(table_mod_std_meta_##X);									\
	}																	\
	if ((ACTION_BITMAP & BIT_MASK_GENERATE_DIGIST) != 0) {			    \
		apply(table_generate_digest_##X);								\
	}																	\
	if ((ACTION_BITMAP & BIT_MASK_ADD ) != 0) {							\
		apply(table_add_##X);											\
	}																	\
	if ((ACTION_BITMAP & BIT_MASK_SUBTRACT ) != 0) {					\
		apply(table_subtract_##X);										\
	}																	\
	if ((ACTION_BITMAP & BIT_MASK_REGISTER) != 0) {						\
		apply(table_register_##X);										\
	}																	\
	if ((ACTION_BITMAP & BIT_MASK_COUNTER) != 0) {						\
		apply(table_counter_##X);										\
	}																	\
	if ((ACTION_BITMAP & BIT_MASK_HASH) != 0) {							\
	    apply(table_hash_##X);											\
	}																	\				
	if ((ACTION_BITMAP & BIT_MASK_PROFILE) != 0) {						\
	    apply(table_action_profile_##X);								\
	}																	\
}																		\
table table_add_##X {													\
	reads {																\
		ACTION_ID : exact;												\
	}																	\
	actions {															\
		action_add_header_with_const;									\
		action_add_meta_with_const;										\
		action_add_header_with_header;									\
		action_add_meta_with_header;									\
		action_add_header_with_meta;									\
		action_add_meta_with_meta;										\
	}																	\
}																		\
table table_generate_digest_##X {										\
	reads {																\
		ACTION_ID : exact;												\
	}																	\
	actions {															\
		action_gen_digest;												\
		action_gen_watch_digest;   									    \
		action_gen_debug_digest;										\
	}																	\
}																		\
table table_subtract_##X {												\
	reads {																\
		ACTION_ID : exact;												\
	}																	\
	actions {															\
		action_subtract_const_from_header;								\
		action_subtract_const_from_meta;								\
		action_subtract_header_from_header;								\
		action_subtract_header_from_meta;								\
		action_subtract_meta_from_header;								\
		action_subtract_meta_from_meta;									\
	}																	\
}																		\
table table_mod_std_meta_##X {											\
	reads {																\
		ACTION_ID : exact;												\
	}																	\
	actions {															\
		action_mod_std_meta;											\
		action_loopback;												\
		action_forward;													\
		action_drop;													\
	}																	\
}																		\
table table_mod_header_with_const_##X {									\
	reads {																\
		ACTION_ID : exact;												\
	}																	\
	actions {															\
		action_mod_header_with_const;									\
		action_mod_header_with_const_and_checksum;						\
	}																	\
}																		\
table table_mod_meta_with_const_##X {									\
	reads {																\
		ACTION_ID : exact;												\
	}																	\
	actions {															\
		action_mod_meta_with_const;										\
	}																	\
}																		\
table table_mod_header_with_meta_##X {									\
	reads {																\
		ACTION_ID : exact;												\
	}																	\
	actions {															\
		action_mod_header_with_meta_1;									\
		action_mod_header_with_meta_2;									\
		action_mod_header_with_meta_3;									\
	}																	\
}																		\
table table_mod_meta_with_meta_##X {									\
	reads {																\
		ACTION_ID : exact;												\
	}																	\
	actions {															\
		action_mod_meta_with_meta_1;									\
		action_mod_meta_with_meta_2;									\
		action_mod_meta_with_meta_3;									\
	}																	\
}																		\
table table_mod_header_with_header_##X {								\
	reads {																\
		ACTION_ID : exact;												\
	}																	\
	actions {															\
		action_mod_header_with_header_1;								\
		action_mod_header_with_header_2;								\
		action_mod_header_with_header_3;								\
	}																	\
}																		\
table table_mod_meta_with_header_##X {									\
	reads {																\
		ACTION_ID : exact;												\
	}																	\
	actions {															\
		action_mod_meta_with_header_1;									\
		action_mod_meta_with_header_2;									\
		action_mod_meta_with_header_3;									\
	}																	\
}																		\
table table_add_header_##X {											\
	reads {																\
		ACTION_ID : exact;												\
	}																	\
	actions {															\
		action_add_header_1;											\
	}																	\
}																		\	
table table_remove_header_##X {											\
	reads {																\
		ACTION_ID : exact;												\
	}																	\
	actions {															\
		action_remove_header_1;											\
	}																	\
}																		\
table table_hash_##X {													\
	reads {																\
		ACTION_ID : exact;											\
	}																	\
	actions {															\
		action_hash;													\
	}																	\
}																		\
table table_action_profile_##X {   										\
	reads {																\
		ACTION_ID : exact;											\
	}																	\
	action_profile : hash_profile;  									\
}																		\
table table_counter_##X {												\
	reads {																\
		ACTION_ID : exact;											\
	}																	\
	actions {															\
		packet_count;													\
		packet_count_clear;												\
	}																	\
}																		\
table table_register_##X {												\
	reads {																\
		ACTION_ID : exact;											\
	}																	\
	actions {															\
		action_load_register_into_header;								\
		action_load_register_into_meta;									\
		action_write_header_into_register;								\
		action_wirte_meta_into_register;								\
		action_wirte_const_into_register;								\
	}																	\
}																		\
counter counter_##X {													\
 	type : packets_and_bytes;											\
	direct : table_counter_##X;											\
}																		


#endif