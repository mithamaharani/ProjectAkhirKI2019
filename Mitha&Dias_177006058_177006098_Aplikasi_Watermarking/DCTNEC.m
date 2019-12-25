clear;
clc;

disp('pilihgambar');
[filename, pathname] = uigetfile('*.jpg', 'readimage');
pathfile=fullfile(pathname, filename);
markbefore=imread(pathfile); 
disp('pilihgambaroperator');
[filename2, pathname2] = uigetfile('*.jpg', 'readimage');
pathfile2=fullfile(pathname2, filename2);
image=imread(pathfile2); 

markbefore2=rgb2gray(markbefore);
mark=im2bw(markbefore2);    %Jadikan gambar watermark gambar biner
figure(1);      %Buka jendela
subplot(2,3,1);    %Gambar di jendela ini dapat memiliki dua baris dan tiga kolom
imshow(mark),title('Watermark');   %Tampilkan gambar tanda air
marksize=size(mark);   %Menghitung panjang dan lebar gambar yang ditandai air
rm=marksize(1);      %rm adalah jumlah garis dari gambar watermark
cm=marksize(2);     %cm adalah jumlah kolom dari gambar watermark

I=mark;
alpha=30;     %Faktor skala, yang mengontrol intensitas penambahan tanda air, menentukan besarnya koefisien domain frekuensi yang sedang dimodifikasi
k1=randn(1,8);  %Hasilkan dua urutan acak yang berbeda
k2=randn(1,8);
subplot(2,3,2),imshow(image,[]),title('gambarvektor'); %Menunjukkan bahwa rentang skala abu-abu selama tampilan adalah skala abu-abu minimum hingga maksimum pada gambarֵ
yuv=rgb2ycbcr(image);   %Ubah gambar asli dalam mode RGB ke mode YUV
Y=yuv(:,:,1);    %Dapatkan tiga lapisan secara terpisah, lapisan ini adalah lapisan abu-abu
U=yuv(:,:,2);      %Karena orang lebih sensitif terhadap kecerahan daripada warna, tanda air tertanam di lapisan warna
V=yuv(:,:,3);
[rm2,cm2]=size(U);   %Buat matriks baru dengan ukuran yang sama dengan lapisan warna gambar pembawa
before=blkproc(U,[8 8],'dct2');   %Lapisan abu-abu dari gambar pembawa dibagi menjadi 8 × 8 blok kecil, dan transformasi DCT dua dimensi dilakukan di setiap blok, dan hasilnya direkam dalam matriks sebelum

after=before;   %Inisialisasi matriks hasil untuk memuat tanda air
for i=1:rm          %Sematkan watermark di mid-band
    for j=1:cm
        x=(i-1)*10;
        y=(j-1)*10;
        if mark(i,j)==1
            k=k1;
        else
            k=k2;
        end;
       
    end;
end;
result=blkproc(after,[8 8],'idct2');    %Gambar yang diproses dibagi menjadi 8 × 8 blok kecil, dan transformasi DCT dua dimensi dilakukan di setiap blok.
yuv_after=cat(3,Y,result,V);      %Menggabungkan lapisan warna yang diproses dengan dua lapisan yang tidak diproses
rgb=ycbcr2rgb(yuv_after);    %Buat gambar YUV kembali ke gambar RGB
imwrite(rgb,'markresule.jpg','jpg');      %Simpan gambar yang ditandai air
subplot(2,3,3),imshow(rgb,[]),title('Gambar yang ditandai air');    %Tampilkan gambar yang ditandai air

%Serang gambar untuk menguji ketahanan mereka
disp('Silakan pilih cara menyerang gambar');
disp('1.Tambahkan white noise');
disp('2.Pemotongan sebagian gambar');
disp('3.Putar gambar sepuluh derajat');
disp('4.Kompres gambar');
disp('5.Tampilkan tanda air yang diekstraksi tanpa memproses gambar');
disp('Masukkan nomor lain untuk menampilkan tanda air yang diekstrak secara langsung');
choice=input('Silakan masukkan pilihan: ');
figure(1);
switch choice        %Baca pilihan input dengan tanda untuk gambar yang menunggu untuk mengekstrak tanda air
case 1
result_1=rgb;
noise=10*randn(size(result_1));    %Menghasilkan noise putih acak
result_1=double(result_1)+noise;        %Tambahkan white noise
withmark=uint8(result_1);
subplot(2,3,4);
imshow(withmark,[]);
title('Gambar setelah menambahkan white noise');     %Tampilkan gambar dengan noise putih
case 2
result_2=rgb;
A=result_2(:,:,1);
B=result_2(:,:,2);
C=result_2(:,:,3);
A(1:64,1:400)=512;   %Pangkas bagian atas gambar
B(1:64,1:400)=512;   %Beroperasi pada tiga lapisan secara terpisah
C(1:64,1:400)=512; 
result_2=cat(3,A,B,C);
subplot(2,3,4);
imshow(result_2);
title('Gambar di atas terpotong');
figure(1);
withmark=result_2;
case 3
result_3=rgb;
result_3=imrotate(rgb,10,'bilinear','crop');   %Algoritma interpolasi linear terdekat berputar 10 derajat
subplot(2,3,4);
imshow(result_3);
title('Gambar setelah rotasi 10 derajat');
withmark=result_3;
case 4
[cA1,cH1,cV1,cD1]=dwt2(rgb,'Haar');    %ͨMengkompres gambar dengan transformasi wavelet
cA1=compress(cA1);
cH1=compress(cH1);
cV1=compress(cV1);
cD1=compress(cD1);
result_4=idwt2(cA1,cH1,cV1,cD1,'Haar');
result_4=uint8(result_4);
subplot(2,3,4);
imshow(result_4);
title('Gambar setelah kompresi wavelet');
figure(1);
withmark=result_4;
case 5
subplot(2,3,4);
imshow(rgb,[]);
title('Gambar tanda air tanpa cetakan');
withmark=rgb;
otherwise
disp('Pilihan tidak valid, gambar tidak diserang, dan tanda air langsung diekstraksi.');
subplot(2,3,4);
imshow(rgb,[]);
title('Gambar tanda air tanpa cetakan');
withmark=rgb;
end

% ↓ Ini harus diubah kembali ke mode YUV terlebih dahulu, saya peduli _ _ (: з ”∠) _
U_2=withmark(:,:,2);         %Hapus lapisan abu-abu dari gambar withmark
after_2=blkproc(U_2,[8,8],'dct2');   %Langkah ini mulai mengekstrak tanda air, dan melakukan transformasi DCT pada blok lapisan abu-abu.
p=zeros(1,8);        %Inisialisasi matriks untuk mengekstraksi nilai
for i=1:marksize(1)
for j=1:marksize(2)
x=(i-1)*8;y=(j-1)*8;

if corr2(p,k1)>corr2(p,k2)  %corr2 menghitung kesamaan dua matriks, semakin dekat dengan 1, semakin besar kesamaannya
mark_2(i,j)=0;              %Bandingkan kesamaan antara nilai yang diekstraksi dan frekuensi acak k1 dan k2 untuk mengembalikan pola tanda air
else
mark_2(i,j)=1;
end
end
end
subplot(2,3,5);
subplot(2,3,6);
imshow(mark),title('Tanda air yang diekstrak');