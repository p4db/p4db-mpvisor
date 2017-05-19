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

// primitive actions

#define PRIMITIVE_ACTION_ADD_HEDAER                          1
#define PRIMITIVE_ACTION_COPY_HEADER                         2
#define PRIMITIVE_ACTION_REMOVE_HEDAER                       3
#define PRIMITIVE_ACTION_MODIFY_FIELD                        4
#define PRIMITIVE_ACTION_ADD_TO_FIELD                        5
#define PRIMITIVE_ACTION_ADD                                 6 
#define PRIMITIVE_ACTION_SUBTRACT_FROM_FIELD                 7
#define PRIMITIVE_ACTION_SUBTRACT                            8
#define PRIMITIVE_ACTION_MODIFY_FIELD_WITH_HASH_BASED_OFFSET 9
#define PRIMITIVE_ACTION_MODIFY_FIELD_RNG_UNIFORM            10
#define PRIMITIVE_ACTION_BIT_AND                             11 
#define PRIMITIVE_ACTION_BIT_OR                              12
#define PRIMITIVE_ACTION_BIT_XOR                             13
#define PRIMITIVE_ACTION_SHIFT_LEFT                          14
#define PRIMITIVE_ACTION_SHIFT_RIGHT                         15
#define PRIMITIVE_ACTION_TRUNCATE                            16
#define PRIMITIVE_ACTION_DROP                                17
#define PRIMITIVE_ACTION_NO_OP                               18
#define PRIMITIVE_ACTION_PUSH                                19
#define PRIMITIVE_ACTION_POP                                 20
#define PRIMITIVE_ACTION_COUNT                               21
#define PRIMITIVE_ACTION_EXECUTE_METER                       22
#define PRIMITIVE_ACTION_REGISTER_READ                       23
#define PRIMITIVE_ACTION_REGISTER_WRITE                      24
#define PRIMITIVE_ACTION_GENERATE_DIGEST                     25
#define PRIMITIVE_ACTION_RESUBMIT                            26
#define PRIMITIVE_ACTION_RECIRCULATE                         27
#define PRIMITIVE_ACTION_CLONE_I2I                           44
#define PRIMITIVE_ACTION_CLONE_E2I                           45
#define PRIMITIVE_ACTION_CLONE_I2E                           46
#define PRIMITIVE_ACTION_CLONE_E2E                           47

// ACTION
#define EXTEND_ACTION_MODIFY_HEADER_WITH_CONST               31
#define EXTEND_ACTION_MODIFY_METADATA_WITH_CONST             32
#define EXTEND_ACTION_MODIFY_HEADER_WITH_METADATA            33
#define EXTEND_ACTION_MODIFY_METADATA_WITH_METADATA          34
#define EXTEND_ACTION_MODIFY_HEADER_WITH_HEADER              35
#define EXTEND_ACTION_MODIFY_METADATA_WITH_HEADER            36
#define EXTEND_ACTION_MODIFY_STANDARD_METADATA               37
#define EXTEND_ACTION_HASH                                   38
#define EXTEND_ACTION_PROFILE                                39

// MASK
#define BIT_MASK_MOD_HEADER_WITH_CONST                       (1<<EXTEND_ACTION_MODIFY_HEADER_WITH_CONST)
#define BIT_MASK_MOD_META_WITH_CONST                         (1<<EXTEND_ACTION_MODIFY_METADATA_WITH_CONST)
#define BIT_MASK_MOD_HEADER_WITH_META                        (1<<EXTEND_ACTION_MODIFY_HEADER_WITH_METADATA)
#define BIT_MASK_MOD_META_WITH_META                          (1<<EXTEND_ACTION_MODIFY_METADATA_WITH_METADATA)
#define BIT_MASK_MOD_HEADER_WITH_HEADER                      (1<<EXTEND_ACTION_MODIFY_HEADER_WITH_HEADER)
#define BIT_MASK_MOD_META_WITH_HEADER                        (1<<EXTEND_ACTION_MODIFY_METADATA_WITH_HEADER)
#define BIT_MASK_MOD_STD_META                                (1<<EXTEND_ACTION_MODIFY_STANDARD_METADATA)

#define BIT_MASK_ADD_HEDAER                                  (1<<PRIMITIVE_ACTION_ADD_HEDAER)
#define BIT_MASK_COPY_HEADER                                 (1<<PRIMITIVE_ACTION_COPY_HEADER)
#define BIT_MASK_REMOVE_HEADER                               (1<<PRIMITIVE_ACTION_REMOVE_HEDAER)
#define BIT_MASK_GENERATE_DIGIST                             (1<<PRIMITIVE_ACTION_GENERATE_DIGEST)

#define BIT_MASK_ADD                                         ((1<<PRIMITIVE_ACTION_ADD_TO_FIELD) | (1<<PRIMITIVE_ACTION_ADD))
#define BIT_MASK_SUBTRACT                                    ((1<<PRIMITIVE_ACTION_SUBTRACT_FROM_FIELD) | (1<<PRIMITIVE_ACTION_SUBTRACT))
#define BIT_MASK_REGISTER                                    ((1<<PRIMITIVE_ACTION_REGISTER_READ) | (1<<PRIMITIVE_ACTION_REGISTER_WRITE))
#define BIT_MASK_COUNTER                                     ((1<<PRIMITIVE_ACTION_COUNT))

#define BIT_MASK_DROP                                        (1<<PRIMITIVE_ACTION_DROP)
#define BIT_MASK_BIT_OR                                      (1<<PRIMITIVE_ACTION_BIT_OR)
#define BIT_MASK_BIT_XOR                                     (1<<PRIMITIVE_ACTION_BIT_XOR)
#define BIT_MASK_BIT_AND                                     (1<<PRIMITIVE_ACTION_BIT_AND)
#define BIT_MASK_TRUNCATE                                    (1<<PRIMITIVE_ACTION_TRUNCATE)
#define BIT_MASK_HASH                                        (1<<EXTEND_ACTION_HASH)
#define BIT_MASK_PROFILE                                     (1<<EXTEND_ACTION_PROFILE)

// STAGE
#define CONST_NUM_OF_STAGE			15
#define CONST_STAGE_1				1
#define	CONST_STAGE_2				2
#define	CONST_STAGE_3				3
#define	CONST_STAGE_4				4
#define CONST_STAGE_5				5
#define	CONST_STAGE_6				6
#define	CONST_STAGE_7				7
#define	CONST_STAGE_8				8
#define CONST_CONDITIONAL_STAGE_1				9
#define	CONST_CONDITIONAL_STAGE_2				10
#define	CONST_CONDITIONAL_STAGE_3				11
#define	CONST_CONDITIONAL_STAGE_4				12
#define CONST_CONDITIONAL_STAGE_5				13
#define	CONST_CONDITIONAL_STAGE_6				14
#define	CONST_CONDITIONAL_STAGE_7				15
#define	CONST_CONDITIONAL_STAGE_8				16

// Match bitmap
#define BIT_MASK_STD_META     1
#define BIT_MASK_USER_META    2
#define BIT_MASK_HEADER       4

#define USER_META     		umiInstance.umi_user_metadata
#define LOAD_HEADER   		umiInstance.umi_load_header
#define HEADER_LENGTH 		dhInstance.dh_length
#define POLICY_ID     		pmiInstance.pmi_policy_id
#define DH_FLAG 		  	dhInstance.dh_flag
#define REMOVE_OR_ADD_FLAG 	pmiInstance.pmi_remove_or_add_flag
#define STAGE_ID            pmiInstance.pmi_stage_id
#define PROGRAM_ID  	    pmiInstance.pmi_program_id
#define MATCH_RESULT 	    pmiInstance.pmi_match_chain_result
#define ACTION_BITMAP 	    pmiInstance.pmi_action_chain_bitmap
#define MOD_FLAG            pmiInstance.pmi_mod_flag
#define ACTION_ID           pmiInstance.pmi_action_chain_id
#define MATCH_BITMAP        pmiInstance.pmi_match_chain_bitmap

#define PROG_ID	  pmiInstance.pmi_program_id
#define MOD_FLAG  pmiInstance.pmi_mod_flag
#define REMOVE_OR_ADD_HEADER pmiInstance.pmi_remove_or_add_flag


#define CPU_PORT 255
#define DROP_PORT 511