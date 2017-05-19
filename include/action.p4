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


#ifndef HYPERVISOR_ACTION
#define HYPERVISOR_ACTION
//------------------Actions for P4 primitives----------------


//-----------------------------------------------------------
action noop () {

}


//-----------------------------------------------------------
action packet_count (index) {
	register_read(pmiInstance.pmi_counter, global_register, index);
	register_write(global_register, index, pmiInstance.pmi_counter + 1);
}

action packet_count_clear (index) {
	register_write(global_register, index, 0);
}


//-----------------------------------------------------------
action action_loopback() {
	modify_field(standard_metadata.egress_spec, 
		standard_metadata.ingress_port);
}

//-----------------------------------------------------------
action action_forward(port) {
	modify_field(standard_metadata.egress_spec, port);
}

//-----------------------------------------------------------
action action_drop() {
	drop();
} 

//-----------------------------------------------------------
action action_gen_digest(receiver) {
	generate_digest(receiver, digest_list);
}


//-----------------------------------------------------------
action action_gen_watch_digest(receiver) {
	generate_digest(receiver, watch_digist_list);
}

//-----------------------------------------------------------
action action_gen_debug_digest(receiver) {
	generate_digest(receiver, debug_digist_list);
}

//-----------------------------------------------------------
action action_add_header_with_const(value1, mask1) {
	bit_or(LOAD_HEADER, LOAD_HEADER & (~mask1),
		(LOAD_HEADER + value1) & mask1);
}

//-----------------------------------------------------------
action action_add_meta_with_const(value1, mask1) {
	bit_or(USER_META, USER_META & (~mask1),
		(USER_META + value1) & mask1);
}

//----------------------------------------------------------
action action_add_header_with_header(left1, right1, mask1) {
	bit_or(LOAD_HEADER, LOAD_HEADER & (~mask1), 
		(LOAD_HEADER + (((LOAD_HEADER<<left1)>>right1)&mask1)) & mask1);
}

//-----------------------------------------------------------
action action_add_meta_with_header(left1, right1, mask1) {
	bit_or(USER_META, USER_META & (~mask1), 
		(USER_META + (((LOAD_HEADER<<left1)>>right1)&mask1)) & mask1);
}

//-----------------------------------------------------------
action action_add_header_with_meta(left1, right1, mask1) {
	bit_or(LOAD_HEADER, LOAD_HEADER & (~mask1), 
		(LOAD_HEADER + (((USER_META<<left1)>>right1)&mask1)) & mask1);
}

//-----------------------------------------------------------
action action_add_meta_with_meta(left1, right1, mask1) {
	bit_or(USER_META, USER_META & (~mask1), 
		(USER_META + (((USER_META<<left1)>>right1)&mask1)) & mask1);
}

//-----------------------------------------------------------
action action_subtract_const_from_header(value1, mask1) {
	bit_or(LOAD_HEADER, LOAD_HEADER & (~mask1), 
		(LOAD_HEADER - value1) & mask1);
}

//-----------------------------------------------------------
action action_subtract_const_from_meta(value1, mask1) {
	bit_or(USER_META, USER_META & (~mask1), 
		(USER_META - value1) & mask1);
}

//-----------------------------------------------------------
action action_subtract_header_from_header(left1, right1, mask1) {
	bit_or(LOAD_HEADER, LOAD_HEADER & (~mask1), 
		(LOAD_HEADER - (((LOAD_HEADER<<left1)>>right1)&mask1)) & mask1);
}

//-----------------------------------------------------------
action action_subtract_header_from_meta(left1, right1, mask1) {
	bit_or(USER_META, USER_META & (~mask1), 
		(USER_META - (((LOAD_HEADER<<left1)>>right1)&mask1)) & mask1);
}

//-----------------------------------------------------------
action action_subtract_meta_from_header(left1, right1, mask1) {
	bit_or(LOAD_HEADER, LOAD_HEADER & (~mask1), 
		(LOAD_HEADER - (((USER_META<<left1)>>right1)&mask1)) & mask1);
}

//-----------------------------------------------------------
action action_subtract_meta_from_meta(left1, right1, mask1) {
	bit_or(USER_META, USER_META & (~mask1), 
		(USER_META - (((USER_META<<left1)>>right1)&mask1)) & mask1);
}

//-----------------------------------------------------------
action action_add_header_1(value, mask1, mask2, length1) {
	push(hsInstance, length1*1);

	bit_or(LOAD_HEADER, LOAD_HEADER & mask1, 
		(LOAD_HEADER & (~mask1) )>>(length1*8));
	add_to_field(HEADER_LENGTH, length1);
	action_mod_header_with_const(value, mask2);
	modify_field(dhInstance.dh_length, HEADER_LENGTH);
	
	modify_field(REMOVE_OR_ADD_FLAG, 1);
	modify_field(MOD_FLAG, 1);
}

//-----------------------------------------------------------
action action_remove_header_1(mask1, mask2, length1) {
	push(hsInstance, length1*1);
	subtract_from_field(HEADER_LENGTH, length1);
	
	modify_field(hsInstance[0].hs_byte, DH_FLAG);
	modify_field(hsInstance[1].hs_byte, HEADER_LENGTH);
	modify_field(hsInstance[2].hs_byte, (POLICY_ID>>16)&0xFF);
	modify_field(hsInstance[3].hs_byte, (POLICY_ID) & 0xFF);

	remove_header(dhInstance);

	bit_or(LOAD_HEADER, LOAD_HEADER & mask1, 
		(LOAD_HEADER & mask2)<<(length1*8));
	
	modify_field(REMOVE_OR_ADD_FLAG, 1);
	modify_field(MOD_FLAG, 1);
}

//-----------------------------------------------------------
action action_mod_header_with_const(value, mask1) {
	bit_or(LOAD_HEADER, (LOAD_HEADER & ~mask1), (value & mask1));
	modify_field(MOD_FLAG, 1);
}

//-----------------------------------------------------------
action action_mod_header_with_const_and_checksum(value, 
						mask1, value1, value2, offset1) {
	action_mod_header_with_const(value, mask1);
	action_update_transport_checksum(value1,
		 value2, offset1);
}

//-----------------------------------------------------------
action action_mod_meta_with_const(value, mask1) {
	bit_or(USER_META, (USER_META & ~mask1), 
		(value & mask1));
}

//-----------------------------------------------------------
action action_mod_std_meta(val1, mask1, val2, mask2, 
									val3, mask3, val4, mask4) {
	bit_or(standard_metadata.egress_spec, 
		standard_metadata.egress_spec & (~mask1), val1 & mask1);
	bit_or(standard_metadata.egress_port, 
		standard_metadata.egress_port & (~mask2), val2 & mask2);
	bit_or(standard_metadata.ingress_port, 
		standard_metadata.ingress_port & (~mask3), val3 & mask3);
	bit_or(standard_metadata.packet_length, 
		standard_metadata.packet_length & (~mask4), val4 & mask4);
}

//----------------------------------------------------------
action action_mod_header_with_meta_1(left1, right1, mask1) {
    bit_or(LOAD_HEADER, (LOAD_HEADER & ~mask1),
		 (((USER_META << left1) >> right1) & mask1));
	modify_field(MOD_FLAG, 1);
}

//-----------------------------------------------------------
action action_mod_header_with_meta_2(left1, right1, mask1, 
									left2, right2, mask2) {
    action_mod_header_with_meta_1(left1, right1, mask1);
	action_mod_header_with_meta_1(left2, right2, mask2);
}

//-----------------------------------------------------------
action action_mod_header_with_meta_3(left1, right1, mask1, 
				left2, right2, mask2, left3, right3, mask3) {
    action_mod_header_with_meta_1(left1, right1, mask1);
	action_mod_header_with_meta_1(left2, right2, mask2);
	action_mod_header_with_meta_1(left3, right3, mask3);
}

//-----------------------------------------------------------

action action_mod_meta_with_meta_1(left1, right1, mask1) {
    bit_or(USER_META, (USER_META & ~mask1), 
		(((USER_META << left1) >> right1) & mask1));
}

//-----------------------------------------------------------
action action_mod_meta_with_meta_2(left1, right1, mask1, 
									left2, right2, mask2) {
    action_mod_meta_with_meta_1(left1, right1, mask1);
	action_mod_meta_with_meta_1(left2, right2, mask2);
}

//-----------------------------------------------------------
action action_mod_meta_with_meta_3(left1, right1, mask1, 
				left2, right2, mask2,left3, right3, mask3) {
	action_mod_meta_with_meta_1(left1, right1, mask1);
	action_mod_meta_with_meta_1(left2, right2, mask2);
	action_mod_meta_with_meta_1(left3, right3, mask3);   
}

//----------------------------------------------------------
action action_mod_header_with_header_1(left1, right1, mask1) {
    bit_or(USER_META, (LOAD_HEADER & ~mask1), 
		(((LOAD_HEADER << left1) >> right1) & mask1));

	modify_field(MOD_FLAG, 1);
}

//-----------------------------------------------------------
action action_mod_header_with_header_2(left1, right1, mask1, 
										left2, right2, mask2) {
    action_mod_header_with_header_1(left1, right1, mask1);
	action_mod_header_with_header_1(left2, right2, mask2);
}

//-----------------------------------------------------------
action action_mod_header_with_header_3(left1, right1, mask1, 
				left2, right2, mask2, left3, right3, mask3) {
    action_mod_header_with_header_1(left1, right1, mask1);
	action_mod_header_with_header_1(left2, right2, mask2);
	action_mod_header_with_header_1(left3, right3, mask3);
}


//-----------------------------------------------------------
action action_mod_meta_with_header_1(left1, right1, mask1) {
    bit_or(USER_META, (LOAD_HEADER & ~mask1), 
		(((LOAD_HEADER << left1) >> right1) & mask1));
}

//-----------------------------------------------------------
action action_mod_meta_with_header_2(left1, right1, mask1, 
									left2, right2, mask2) {
    action_mod_meta_with_header_1(left1, right1, mask1);
	action_mod_meta_with_header_1(left2, right2, mask2);
}

//-----------------------------------------------------------
action action_mod_meta_with_header_3(left1, right1, mask1, 
				left2, right2, mask2, left3, right3, mask3) {
    action_mod_meta_with_header_1(left1, right1, mask1);
	action_mod_meta_with_header_1(left2, right2, mask2);
	action_mod_meta_with_header_1(left3, right3, mask3);
}


//-----------------------------------------------------------
action action_recirculate(progid) {
	modify_field(pmiInstance.pmi_recirculate_flag, 1);
	modify_field(pmiInstance.pmi_remove_or_add_flag, 0);
	modify_field(pmiInstance.pmi_program_id, progid); 
	recirculate( flInstance_with_umeta );
}

//-----------------------------------------------------------
action action_resubmit(progid) {
	modify_field(pmiInstance.pmi_recirculate_flag, 1);
	modify_field(pmiInstance.pmi_program_id, progid);
	resubmit(flInstance_with_umeta);
}

//-----------------------------------------------------------
action action_load_register_into_header(index, left1, mask1) {
	register_read(context_data.r5, global_register, index);
	bit_or(LOAD_HEADER, LOAD_HEADER & (~mask1), 
		(context_data.r5<<left1) & mask1);

	modify_field(MOD_FLAG, 1);
}

//-----------------------------------------------------------
action action_load_register_into_meta(index, left1, mask1) {
	register_read(context_data.r5, global_register, index);
	bit_or(USER_META, USER_META & (~mask1), 
		(context_data.r5<<left1) & mask1);
}

//-----------------------------------------------------------
action action_write_header_into_register(index, right1, mask1) {
	register_write(global_register, index, 
		(LOAD_HEADER>>right1) & mask1);
}

//-----------------------------------------------------------
action action_wirte_meta_into_register(index, right1, mask1) {
	register_write(global_register, index, 
		(USER_META>>right1) & mask1);
}

//-----------------------------------------------------------
action action_wirte_const_into_register(index, value, mask1) {
	register_write(global_register, index, value & mask1);
}

//-----------------------------------------------------------
action action_hash(header_mask) {
	modify_field(pmiInstance.pmi_hash, (LOAD_HEADER&header_mask) & 0xFFFF);
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 16) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 32) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 48) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 64) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 80) & 0xFFFF);
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 96) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 112) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 128) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 144) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 160) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 176) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 192) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 208) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 224) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 240) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 256) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 272) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 288) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 304) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 320) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 336) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 352) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 368) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 384) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 400) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 416) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 432) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 448) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 464) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 480) & 0xFFFF);
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 496) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 512) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 528) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 544) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 560) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 576) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 592) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 608) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 624) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 640) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 656) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 672) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 688) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 704) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 720) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 736) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 752) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 768) & 0xFFFF); 
	bit_xor(pmiInstance.pmi_hash, pmiInstance.pmi_hash, ((LOAD_HEADER&header_mask) >> 784) & 0xFFFF); 
}


action_profile hash_profile {
	actions {
		action_forward;
		noop;
	}
	dynamic_action_selection : hash_action_selector;
}

field_list_calculation hash_calculation { 
	input {	
		hash_field_list; 
	}
	algorithm : crc16; 
	output_width : 16;
}

action_selector hash_action_selector {
	selection_key : hash_calculation;
}

#endif
