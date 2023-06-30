=================================================================================
nal头 + 2字节标识
+---------------+----------------+
|0|1|2|3|4|5|6|7||0|1|2|3|4|5|6|7|
+-+-----------+-----------+------+
|F|  NALtype  |  LayerID  |  TID |
+-+-------------+---------+------+
F: 必须为0，表示有效；为1的话表示无效。

NALType: 6-bits NALType 确定NAL的类型，其中VCL NAL和non-VCL NAL各有32类。0-31是vcl nal单元；32-63，是非vcl nal单元。VCL是指携带编码数据的数据流，而non-VCL则是控制数据流.

LayerID: 表示NAL所在的Access unit所属的层，该字段是为了HEVC的继续扩展设置。也就是目前都是0，以后的扩展可能会用到。

TID: 3 bit，至少有一个bit为1
=================================================================================

前面 4个字节位00 00 00 01 为nul头

下面两个字节为40 01  ====》二进制 0100 0000 0000 0001

F  ： 0

NalType：100 000 ==》32  =》VPS

LayerID：0 0000 0==》0

TID：001 ==》1

再根据H265的NALU类型定义分析

数据		nuh_unit_type	语义				缩写
00 00 00 01 40 01	32	视频参数集			VPS
00 00 00 01 42 01	33	序列参数集			SPS
00 00 00 01 44 01	34	图像参数集			PPS
00 00 00 01 4E 01	39	补充增强信息			SEI
00 00 00 01 26 01	19	RADL图像的IDR图像的SS编码数据	IDR
00 00 00 01 02 01	1	被参考的后置图像，且非TSA、非STSA的SS编码数据	non

================================================================================
                //解析sps获取fps和宽高参数
                //       01 01 60 00 00 03  00 00 03 00 00 03 00 00
                // 03 00 78 A0 03 C0 80 10  E7 F9 6B BB CD DD C9 75
                // 80 B5 01 01 01 04 00 00  0F A4 00 01 D4 C0 AE 11
                // 08 20 00 
                //sps_video_parameter_set_id    u(4)
                //sps_max_sub_layers_minus1     u(3)
                //sps_temporal_id_nesting_flag  u(1)
                //00 00 03 时，03为转义字符，跳过，不解析
                //profile_tier_level( 1, sps_max_sub_layers_minus1 )    u(8)+u(1)*32+u(4)+u(43)+u(1)+u(8)=u(96)=12byte + 4个03
                //sps_seq_parameter_set_id      ue(v)   u(1):1  --->0
                //chroma_format_idc             ue(v)   u(3):010--->1
                //pic_width_in_luma_samples     ue(v)   u(21):0000 0000 0011 1100 0000 1    --->1920
                //pic_height_in_luma_samples    ue(v)   u(21):000 0000 0001 0000 1110 01    --->1080
                //conformance_window_flag       u(1)    1
                //conf_win_left_offset          ue(v)   u(1):1  --->0
                //conf_win_right_offset         ue(v)   u(1):1  --->0
                //conf_win_top_offset           ue(v)   u(1):1  --->0
                //conf_win_bottom_offset        ue(v)   u(1):1  --->0
                //bit_depth_luma_minus8         ue(v)   u(1):1  --->0
                //bit_depth_chroma_minus8       ue(v)   u(1):1  --->0
                //log2_max_pic_order_cnt_lsb_minus4 ue(v) u(5):00101  --->4
                //sps_sub_layer_ordering_info_present_flag
                //.....
                //vui_parameters_present_flag   u(1)    1
                //....
                //vui_num_units_in_tick         u(32)   
                //vui_time_scale                u(32)

                //res = fread(buf, sizeof(char), strLen + 2, fp);
================================================================================
