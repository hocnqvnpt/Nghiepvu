/* ------ VI --------------- */
select ma_tb, ngay_dky_vi, ma_hrm, 'VI VNPT' loai from ttkdhcm_ktnv.hcm_vnptpay_ketqua 
where ngay_dky_vi between to_date('01/09/2024 00:00:01','dd/mm/yyyy hh24:mi:ss') and to_date('30/09/2024 23:59:59','dd/mm/yyyy hh24:mi:ss') ;

/* ---------- MOBILE MONEY ------------ */
select ma_tb, ngay_dky_mm, ma_hrm, 'MOBILE MONEY' loai from ttkdhcm_ktnv.hcm_vmoney_ketqua 
where ngay_dky_mm between to_date('01/09/2024 00:00:01','dd/mm/yyyy hh24:mi:ss') and to_date('30/09/2024 23:59:59','dd/mm/yyyy hh24:mi:ss') ;

/* --------- APP MYVNPT ------------ */
select ma_tb, ngay_active, ma_hrm, 'APP MYVNPT' loai from ttkdhcm_ktnv.HCM_VNPTAPP_ACTIVE 
where ngay_active between to_date('01/09/2024 00:00:01','dd/mm/yyyy hh24:mi:ss') and to_date('30/09/2024 23:59:59','dd/mm/yyyy hh24:mi:ss') ;
;

/* ------------------ UPDATE VINAGIFT ------------------- */
-- web http://10.70.115.121/ -> tang qua -> bao cao voucher
update NV_vinagift_202408_CT a set (a.ten_nv,a.ma_vtcv,a.ten_vtcv,a.ma_to,a.ten_to,a.ma_pb,a.ten_pb)
                    =(select ten_nv,ma_vtcv,ten_vtcv,ma_to,ten_to,ma_pb,ten_pb 
                      from ttkd_bsc.nhanvien where manv_hrm=a.manv_hrm and thang=202408) where a.manv_hrm is not null ;
commit ;
select distinct manv_cn,nhanvien_cn from NV_vinagift_202408_CT where manv_hrm is null ;
select * from NV_vinagift_202408_CT where manv_hrm is null ;

/* ------------------ UPDATE USSD ------------------- */

/* SMRS vao mail tap doan, VAO  PHAN TICH -> NHOM BAO CAO DOI SIM 4G -> BC CHI TIET DOI SIM 4G - hh24:mi:ss */

update NV_ussd_202408_CT a set a.manv_hrm=(select ma_nv from ttkd_bsc.nhanvien where thang = 202408 and user_ccbs=a.ccbs_user)
where a.manv_hrm is null ;
commit ;

update NV_ussd_202408_CT a set (a.ten_nv,a.ma_vtcv,a.ten_vtcv,a.ma_to,a.ten_to,a.ma_pb,a.ten_pb)
                    =(select ten_nv,ma_vtcv,ten_vtcv,ma_to,ten_to,ma_pb,ten_pb 
                      from ttkd_bsc.nhanvien where manv_hrm=a.manv_hrm  and thang=202408) where a.manv_hrm is not null ;
commit ;

select distinct ccbs_user from NV_ussd_202408_CT where manv_hrm is null ;
--user_ccbs in ('ctv029090_hcm','ctv070850_hcm','ctv080957_hcm','ctv_giatbtmi_hcm','ctv_hoanth_hcm','ctv_nhannt01_hcm','ctv_nhutnm88_hcm','ctv_uyentlt_hcm')
/* ---------------------------- CCOS -------------------------------- */

/* link  ccos.vnpt.vn  vao GQKN -> bao cao thong ke -> bao cao tong hop VTT -> vao sl tiep nhan - sl da xu ly */

update NV_ccos_202408_CT set ma_tb='84'||trim(ma_tb);
commit ;

update NV_CCOS_202408_CT a set (a.manv_hrm,a.ten_nv,a.ma_vtcv,a.ten_vtcv,a.ma_to,a.ten_to,a.ma_pb,a.ten_pb)
                    =(select manv_hrm,ten_nv,ma_vtcv,ten_vtcv,ma_to,ten_to,ma_pb,ten_pb 
                      from ttkd_bsc.nhanvien where user_ccos=a.user_ccos and thang=202408) ;
commit ;

select * from NV_CCOS_202408_CT where manv_hrm is null ;
/* --------------- NGHIEP VU SAU BAN ------------ */

/* NV */
--select * from NV_202408_CT ;
--drop table NV_202408_CT ;
CREATE TABLE NV_202408_CT AS 
 select a.*, manv_hrm manv_ra_pct, ten_nv tennv_ra_pct, ma_vtcv, ten_vtcv, ma_to mato_ra_pct, ten_to tento_ra_pct, ma_pb mapb_ra_pct, ten_pb tenpb_ra_pct,'SKM' loai,
        (case when ma_vtcv not in('VNP-HNHCM_BHKV_22','VNP-HNHCM_BHKV_28','VNP-HNHCM_BHKV_27') then 1
              when (( a.ma_tiepthi is null and nv.manv_hrm is not null) or a.ma_tiepthi = nv.manv_hrm) 
                    and (ma_vtcv in('VNP-HNHCM_BHKV_22','VNP-HNHCM_BHKV_28','VNP-HNHCM_BHKV_27')) then 1 else 0
         end ) dung_ma_tiepthi
 from 
    ( 
      select to_char(trunc(hdkh.ngay_yc),'yyyymm') thang, hdtb.hdtb_id, hdkh.hdkh_id, hdkh.ma_gd,hdkh.ma_hd, hdkh.ma_kh, hdtb.ma_tb,hdkh.ngay_yc, hdkh.ctv_id, hdkh.nhanvien_id, 
             hdkh.nguoi_cn, hdkh.loaihd_id, (SELECT lhd.ten_loaihd FROM css_hcm.loai_hd lhd WHERE hdkh.loaihd_id=lhd.loaihd_id) TEN_LOAIHD, hdkh.ngaylap_hd,
             hdtb.tthd_id, (SELECT tthd.trangthai_hd FROM css_hcm.trangthai_hd tthd WHERE hdtb.tthd_id=tthd.tthd_id) TRANGTHAI_HD,
             hdkh.khachhang_id, hdtb.thuebao_id, hdkh.donvi_id,hdtb.loaitb_id,hdtb.dichvuvt_id,
            (case when hdkh.ctv_id > 0 then (select ma_nv  from admin_hcm.nhanvien where nhanvien_id = hdkh.ctv_id and rownum=1) else null end) ma_tiepthi,
            (case when hdkh.ctv_id > 0 then (select ten_nv from admin_hcm.nhanvien where nhanvien_id = hdkh.ctv_id and rownum=1) else null end) ten_tiepthi            
      from css_hcm.hd_khachhang hdkh, css_hcm.hd_thuebao hdtb
      where hdkh.hdkh_id=hdtb.hdkh_id and trunc(hdkh.ngay_yc) between to_date('01/08/2024','dd/mm/yyyy') and to_date('31/08/2024','dd/mm/yyyy')
    ) a 
left join ttkd_bsc.nhanvien_202408 nv on a.nhanvien_id = nv.nhanvien_id
;
/*------------ KHIEU NAI -------------- */
--select * from NV_KHIEUNAI_202408_CT ;
--drop table NV_KHIEUNAI_202408_CT ;
create table NV_KHIEUNAI_202408_CT AS 
select a.*,
    nv.manv_hrm manv_ra_pct, nv.ten_nv tennv_ra_pct, nv.ma_vtcv, nv.ten_vtcv ten_vtcv_ra_pct, nv.ma_to mato_ra_pct, nv.ten_to tento_ra_pct, nv.ma_pb mapb_ra_pct, nv.ten_pb tenpb_ra_pct,
    nv1.manv_hrm manv_gq, nv1.ten_nv tennv_gq, nv1.ma_vtcv ma_vtcv_gq, nv1.ten_vtcv ten_vtcv_gq, nv1.ma_to mato_gq, nv1.ten_to tento_gq, nv1.ma_pb mapb_gq, nv1.ten_pb tenpb_gq,
    (Case when ( NV1.ma_vtcv in('VNP-HNHCM_BHKV_22','VNP-HNHCM_BHKV_28','VNP-HNHCM_BHKV_27'))then 'X' else '' end)NV_GQ,  -- nv.manv_hrm=nv1.manv_hrm AND
               'KHN' loai, --kh.ma_kh, kh.ma_gd
              (SELECT MA_KH FROM CSS_HCM.DB_KHACHHANG WHERE KHACHHANG_ID=A.KHACHHANG_ID)MA_KH,
               (select ma_gd from css_hcm.hd_khachhang where khachhang_id=a.khachhang_id and rownum=1)ma_gd
from 
    ( select to_char(trunc(a.ngay_tn),'yyyymm') thang, a.donvi_id, a.thuebao_id,(select khachhang_id from css_hcm.db_thuebao where thuebao_id=a.thuebao_id)khachhang_id,
              a.ma_tb,a.loaitb_id,a.dichvuvt_id, a.ngay_tn, a.nguoi_cn, a.nhanvien_id, a.nhanvien_gq_id, a.ttkn_id,
              (case when a.ttkn_id in(5,6) then 'KHIEU NAI - HOAN THANH' else 'KHIEU NAI - TIEPNHAN' end)TEN_LOAIHD  -- MA_KN, NGAY_GQ
      from qltn_hcm.khieunai a where phanvung_id=28 and a.dichvuvt_id <> 2 
      and trunc(a.ngay_tn) between to_date('01/08/2024','dd/mm/yyyy') and to_date('31/08/2024','dd/mm/yyyy')
    ) a 
--    left join css_hcm.hd_khachhang kh on kh.khachhang_id=a.khachhang_id 
left join ttkd_bsc.nhanvien_202408 nv on a.nhanvien_id = nv.nhanvien_id
left join ttkd_bsc.nhanvien_202408 nv1 on a.nhanvien_gq_id = nv1.nhanvien_id
;  
/* ------------- THU CUOC ----------------- */
--drop table NV_CT_THU_202408_CT ;
create table NV_CT_THU_202408_CT as 
select distinct a.thang,a.phieu_id, a.ngay_tt, a.ma_tb,a.ma_tt,a.dichvuvt_id, a.ma_tn, a.ngay_cn, a.nguoi_cn, a.httt_id,
                nhanvien_id, manv_hrm manv_ra_pct, ten_nv tennv_ra_pct, ma_vtcv, ten_vtcv, ma_to mato_ra_pct, ten_to tento_ra_pct, ma_pb mapb_ra_pct, ten_pb tenpb_ra_pct,
               db.loaitb_id, db.thuebao_id, db.khachhang_id,
               (SELECT MA_KH FROM css_hcm.db_khachhang WHERE khachhang_id=db.khachhang_id)MA_KH,
               (select ma_gd from css_hcm.hd_khachhang where khachhang_id=db.khachhang_id and rownum=1)ma_gd, a.loaihd_id,a.ten_loaihd,'PTH' loai
from 
     ( Select to_char(trunc(a.ngay_tt),'yyyymm') thang, a.phieu_id, a.ngay_tt, a.ma_tt, a.ma_tn, b.nguoi_cn, a.ngay_cn, a.httt_id, b.ma_tb, b.dichvuvt_id, 99 loaihd_id, 'THU CUOC' ten_loaihd
       From qltn_hcm.Bangphieutra a, qltn_hcm.ct_tra b
       Where a.phieu_id=b.phieu_id and b.dichvuvt_Id<>2 and a.ky_cuoc='20240801' and b.ky_cuoc='20240801'
         and trunc(a.ngay_cn) between to_date('01/08/2024','dd/mm/yyyy') and to_date('31/08/2024','dd/mm/yyyy')         
     ) a 
left join css_hcm.db_thuebao db on a.ma_tb=db.ma_tb and a.dichvuvt_id=db.dichvuvt_id
left join ttkd_bsc.nhanvien_202408 nv on a.ma_tn=nv.manv_hrm or a.ma_tn=nv.ma_nv
;
select * from NV_CT_THU_202408_CT  ;
create index NV_CT_THU_202408_CT_matb on NV_CT_THU_202408_CT  (ma_tb) ;

/* ---------------------- VNP ----------------------- */

select * from NV_VNP_202408_CT ;
create table NV_VNP_202408_CT as
--insert into NV_VNP_202408_CT (ma_kh,ma_tb,loai_tb, manv_ra_pct, tennv_ra_pct,ma_vtcv, ten_vtcv, mato_ra_pct, tento_ra_pct, mapb_ra_pct, tenpb_ra_pct, user_cn, ngay_cn, ten_loaihd, ma_gd)
select ma_kh,ma_tb,loai_tb, manv_ra_pct, tennv_ra_pct,ma_vtcv, ten_vtcv, mato_ra_pct, tento_ra_pct, mapb_ra_pct, tenpb_ra_pct, user_cn, ngay_cn, ten_loaihd, ma_gd
from 
(
    select cast(a.ma_kh as varchar(20))ma_kh,cast(a.ma_tb as varchar(30))ma_tb,(case when a.loai_tb is null then 'CARD' else a.loai_tb end )loai_tb, 
              nv.manv_hrm manv_ra_pct,nv.ten_nv tennv_ra_pct,nv.ma_vtcv,nv.ten_vtcv,nv.ma_to mato_ra_pct,
              ( case when substr(a.user_cn,1,2) like 'dl%' then 'DAI LY' else nv.ten_to end ) tento_ra_pct, nv.ma_pb mapb_ra_pct,
              ( case when substr(a.user_cn,1,2) like 'dl%' then (select buucuc from nhuy.userld_202408_goc where user_ld=a.user_cn) 
                     else nv.ten_pb end ) tenpb_ra_pct,
              a.user_cn,a.ngay_cn,(case when a.loai_cn='THANH LY' then 'THANH LY/PTOC' else a.loai_cn end) ten_loaihd,
              (select ma_hd from danhba_dds_082024 where ma_tb=a.ma_tb and ma_kh=a.ma_kh and rownum=1)ma_gd
    from 
         ( select a.* from ccs_hcm.SOLIEU_CCBS_202408@ttkddbbk2 a 
            where trunc(ngay_cn) between to_date('01/08/2024','dd/mm/yyyy') and to_date('31/08/2024','dd/mm/yyyy')
         ) a left join ttkd_bsc.nhanvien nv on a.user_cn=nv.user_ccbs and nv.thang=202408
) 
;
commit ;
