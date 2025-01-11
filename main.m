clc;
clear;
rf_freq = 915e6;

sf = 12;
bw = 500e3;
fs = 25e6;
% fs = 4*bw;
cr = 1;
tag_period = 0.1024;
tag_num = 2;

ysp = PPLoRa_PHY(rf_freq, sf, bw, fs, tag_period,tag_num);

n = 6; % n为数组长度
% 随机生成一组数据
v = randi([0, 4095], 1, n)
s = ysp.modulate(v);
% ysp.sig = s;
v1 = randi([0, 1], 1, n)
v2 = randi([0, 1], 1, n)
% 标签1与标签2
temp1 = ysp.new_PPLoRa_modulate(v1,s,256e3);
temp2 = ysp.new_PPLoRa_modulate(v2,s,260e3);
ysp.sig = s + temp1 + temp2;
rs = ysp.PPLoRa_demodulate()

% 验证是否正确

% 获取标签1和标签2的解码数据
tag_data1 = rs(2, :);
tag_data2 = rs(3, :);

% 原始发送的标签1和标签2数据
original_tag1 = v1;
original_tag2 = v2;

% 计算标签1解码是否正确
correctness_tag1 = all(tag_data1 == original_tag1);

% 计算标签2解码是否正确
correctness_tag2 = all(tag_data2 == original_tag2);

if correctness_tag1
    disp('标签1数据解码正确');
else
    disp('标签1数据解码错误');
end

if correctness_tag2
    disp('标签2数据解码正确');
else
    disp('标签2数据解码错误');
end

