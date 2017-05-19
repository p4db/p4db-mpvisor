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

#ifndef HYPERVISOR_CHEKSUM
#define HYPERVISOR_CHEKSUM

#define OFFSET  context_data.r1
#define SUM     context_data.r5
#define RESULT  context_data.r2

//-----------------------------------------------------------
action action_ipv4_checksum(ipv4_offset) {
    modify_field(SUM, 0);
    modify_field(OFFSET, ipv4_offset);

    // DST
    add_to_field(SUM, (LOAD_HEADER>>OFFSET) & 0xFFFF);
    add_to_field(OFFSET, 16);

    add_to_field(SUM, (LOAD_HEADER>>OFFSET) & 0xFFFF);
    add_to_field(OFFSET, 16);

    // SRC
    add_to_field(SUM, (LOAD_HEADER>>OFFSET) & 0xFFFF);
    add_to_field(OFFSET, 16);

    add_to_field(SUM, (LOAD_HEADER>>OFFSET) & 0xFFFF);
    add_to_field(OFFSET, 16);
    
    // Checksum
    add_to_field(OFFSET, 16);

    // TTL + Protocol
    add_to_field(SUM, (LOAD_HEADER>>OFFSET) & 0xFFFF);
    add_to_field(OFFSET, 16);

    // FRAG
    add_to_field(SUM, (LOAD_HEADER>>OFFSET) & 0xFFFF);
    add_to_field(OFFSET, 16);

    // ID
    add_to_field(SUM, (LOAD_HEADER>>OFFSET) & 0xFFFF);
    add_to_field(OFFSET, 16);

    // totalLen
    add_to_field(SUM, (LOAD_HEADER>>OFFSET) & 0xFFFF);
    add_to_field(OFFSET, 16);

    // version+IHL+DSCP
    add_to_field(SUM, (LOAD_HEADER>>OFFSET) & 0xFFFF);
    add_to_field(OFFSET, 16);

    modify_field(RESULT, (SUM + (SUM>>16)) & 0xFFFF);

    action_mod_header_with_const(RESULT, 0xFFFF << (OFFSET + 64));
}

//-----------------------------------------------------------
action action_update_transport_checksum(value1, value2, offset) {
    modify_field(RESULT, value1);
    add_to_field(RESULT, ~value2);
    add_to_field(RESULT, (LOAD_HEADER >> offset) & 0xFFFF);
    action_mod_header_with_const(RESULT, 0xFFFF << offset);
}


control recalculate_checksum {
    apply(table_checksum);
}

table table_checksum {
    reads {
        POLICY_ID : exact;
    }
    actions {
        action_ipv4_checksum;
        action_update_transport_checksum;
        noop;
    }
}

#endif
