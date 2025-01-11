# PPLoRa_PHY MATLAB 代码说明文档

## 一、概述
本 MATLAB 代码实现了 PPLoRa（无源并行 LoRa）系统的物理层功能，主要用于 LoRa 信号的调制、解调、编码和解码操作，特别在处理标签与网关通信及边带信号方面具有重要作用。

## 二、重要函数说明

### （一）`PPLoRa_PHY` 构造函数
- **函数定义**：`function self = PPLoRa_PHY(rf_freq, sf, bw, fs, tag_period, tag_num)`
- **功能描述**：
    - 用于创建 `PPLoRa_PHY` 类的实例。首先会检查 MATLAB 版本是否不低于 R2019b，若低于则报错。接着初始化一系列属性，如设置 `has_header` 为 1（表示有显式头部）、`crc` 为 1（启用 CRC 校验）、`fast_mode` 为 false（非快速执行模式）、`is_debug` 为 false（不输出调试信息）、`hamming_decoding_en` 为 true（启用汉明解码）等。还会生成特定的白化序列 `whitening_seq`、头部校验和矩阵 `header_checksum_matrix` 以及 CRC 生成器对象 `crc_generator`，最后调用 `init` 方法进一步初始化其他相关参数。

### （二）`demodulate` 函数
- **函数定义**：`function [symbols_m, cfo_m, netid_m] = demodulate(self, sig)`
- **功能描述**：
    - 是 LoRa 数据包解调的关键函数。先将 `cfo` 归零并调用 `init` 方法初始化相关参数。若不是 `fast_mode`，会对输入信号 `sig` 进行低通滤波，然后将其重采样为 `2*bw`。通过 `detect` 方法检测前导码，利用 `sync` 方法实现符号同步，在此过程中获取 `NetID` 信息并提取 `payload_len`。接着对数据包中的数据符号进行解调，将结果存入 `symbols_m`，同时记录每个数据包的 `cfo_m` 和 `netid_m`。若未检测到前导码，会发出警告。

### （三）`PPLoRa_demodulate` 函数
- **函数定义**：`function tag_data_matrix = PPLoRa_demodulate(self)`
- **功能描述**：
    - 专门用于标签数据的解调。首先创建一个 `(tag_num + 1)×6` 的零矩阵 `tag_data_matrix` 存储结果。在循环中，以 `(10.25 + i - 1) * sample_num` 为索引调用 `PPLoRa_dechirp` 方法解调。计算非第一行与第一行差值对应的频率，判断是否接近 256000 或 260000，据此设置 `tag_data1` 和 `tag_data2`，最后将相关数据填入 `tag_data_matrix`。


### （四）`new_PPLoRa_modulate` 函数
- **函数定义**：`function s = new_PPLoRa_modulate(self, data, sig, tag_offset)`
- **功能描述**：
    - 同样用于信号调制。以 `self.sample_num` 为符号单位，对 10.25 个 `self.sample_num` 之后的部分，按 `data` 数据操作，1 乘方波，0 保持原信号，同时保留前 10.25 个 `self.sample_num` 信号。

## 三、使用示例
以下是一个简单的使用示例，展示如何使用这些函数进行信号处理：
```matlab
% 设置参数
rf_freq = 915e6;
sf = 12;
bw = 500e3;
fs = 25e6;
tag_period = 0.1024;
tag_num = 2;

% 创建 PPLoRa_PHY 对象
ysp = PPLoRa_PHY(rf_freq, sf, bw, fs, tag_period,tag_num);

% 随机生成数据
n = 6;
v = randi([0, 4095], 1, n);
s = ysp.modulate(v);

v1 = randi([0, 1], 1, n);
v2 = randi([0, 1], 1, n);

% 对标签数据进行调制
temp1 = ysp.new_PPLoRa_modulate(v1,s,256e3);
temp2 = ysp.new_PPLoRa_modulate(v2,s,260e3);
ysp.sig = s + temp1 + temp2;

% 进行解调
rs = ysp.PPLoRa_demodulate();

% 验证标签 1 数据解码是否正确
tag_data1 = rs(2, :);
original_tag1 = v1;
correctness_tag1 = all(tag_data1 == original_tag1);
if correctness_tag1
    disp('标签 1 数据解码正确');
else
    disp('标签 1 数据解码错误');
end

% 验证标签 2 数据解码是否正确
tag_data2 = rs(3, :);
original_tag2 = v2;
correctness_tag2 = all(tag_data2 == original_tag2);
if correctness_tag2
    disp('标签 2 数据解码正确');
else
    disp('标签 2 数据解码错误');
end
```

在上述示例中，首先设置了 LoRa 系统的相关参数，然后创建了 `PPLoRa_PHY` 对象。接着生成了随机数据并进行调制，将调制后的信号相加后进行解调，最后验证标签数据的解码是否正确。用户可以根据实际需求修改参数和数据，以适应不同的应用场景。

请注意，在使用代码时，确保 MATLAB 版本符合要求，并且根据实际情况调整参数设置，以获得最佳的性能和结果。同时，代码中的一些函数可能会受到信号质量、噪声等因素的影响，在实际应用中可能需要进一步优化和处理。 