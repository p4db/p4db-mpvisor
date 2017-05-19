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

#ifndef HYPERVISOR_INSTANCE
#define HYPERVISOR_INSTANCE

#include "config.p4"

/****************************************************
 * Packet header instances
 ***************************************************/
header description_header_t dhInstance ;
header header_stack_t hsInstance[128] ;


/****************************************************
 * Metadata instances
 ***************************************************/
metadata program_metadata_t pmiInstance ;
metadata user_metadata_t umiInstance ;

metadata context_metadata_t context_data;
metadata intrinsic_metadata_t intrinsic_metadata;



/****************************************************
 * Field list instances
 ***************************************************/
#define USER_META     umiInstance.umi_user_metadata
#define LOAD_HEADER   umiInstance.umi_load_header

/****************************************************
 * Field list for resubmit and recirculate
 ***************************************************/
field_list flInstance_with_umeta { 
    pmiInstance;
    umiInstance;
    standard_metadata; 
}

field_list digest_list {
    umiInstance;
    standard_metadata;
}

field_list watch_digist_list {
	LOAD_HEADER;
}

field_list debug_digist_list {
	USER_META;
	LOAD_HEADER;
}


field_list hash_field_list {
    pmiInstance.pmi_hash;
}

#undef USER_META
#undef LOAD_HEADER

/****************************************************
 * Global register
 * Reserved for user programs
 ***************************************************/
register global_register {
    width : REGISTER_WIDTH;
    instance_count : REGISTER_NUMBER;
}

counter ingress_port_counter {											
 	type : packets_and_bytes;
	direct : table_config_at_initial;									
}	

counter egress_port_counter {											
 	type : packets_and_bytes;
	direct : dh_deparse;									
}	


#endif
