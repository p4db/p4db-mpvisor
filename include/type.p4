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

#ifndef HYPERVISOR_TYPE
#define HYPERVISOR_TYPE

/****************************************************
 * intrinsic_metadata_t
 * P4 intrinsic metadata (mandatory)
 ****************************************************/
header_type intrinsic_metadata_t {
	fields {
        ingress_global_timestamp : 48;
        lf_field_list : 8;
        mcast_grp : 16;
        egress_rid : 16;
        resubmit_flag : 8;
        recirculate_flag : 8;
        degist_receiver0 : 8;
        degist_receiver1 : 8;
        degist_receiver2 : 8;
        degist_receiver3 : 8;
        degist_receiver4 : 8;
        degist_receiver5 : 8;
        degist_receiver6 : 8;
        degist_receiver7 : 8;
        degist_receiver8 : 8;
        degist_receiver9 : 8;
	}
}

/****************************************************
 * program_metadata_t
 * Program metadata for control and stage
 ***************************************************/
header_type program_metadata_t {
	fields {
		// Identifiers
		pmi_policy_id  : 16 ; 
		pmi_program_id : 8;
		pmi_stage_id   : 8;

		// Action block variables
		pmi_action_chain_id		: 48; 
		pmi_action_chain_bitmap : 48;
		
		// Match block variable
		pmi_match_chain_result  : 48;
		pmi_match_chain_bitmap  : 3 ;

		pmi_recirculate_flag    : 1 ;      
		pmi_remove_or_add_flag  : 1 ;
		pmi_mod_flag			: 1 ;

		// TODO put them to context_metadata_t
		pmi_op         : 2 ;
		pmi_left_expr  : 16;
		pmi_right_expr : 16;
		
		pmi_counter    : 32;
		pmi_hash       : 16;
	}
}

/****************************************************
 * user_metadata_t
 * Reserved meta-data for programs
 ***************************************************/
header_type user_metadata_t {
	fields {
		umi_user_metadata : 256;
		umi_load_header   : 800;
	}
}

/****************************************************
 * description_header_t
 * Descripe packet headers
 ***************************************************/
header_type description_header_t {
	fields {
		dh_flag : 8;
		dh_length : 8;
		dh_policy_id : 16;
		dh_load_header : *;
	}
	length : dh_length;
	max_length : 128;
}

/****************************************************
 * header_stack_t
 * Used for add_headers, remove_header, push, and \
 * pop operations
 ***************************************************/
header_type header_stack_t {
	fields {
		hs_byte : 8;
	}
}

/****************************************************
 * context_metadata_t
 * Context data and intermediate variables for \
 * arithmetical logic
 ***************************************************/
header_type context_metadata_t {
	fields {
		r1 : 16;
		r2 : 16;
		r3 : 16;
		r4 : 16;
		r5 : 32;
	}
}

#endif
