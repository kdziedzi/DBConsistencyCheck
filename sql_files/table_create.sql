Create table INCONSISTENT_BLOCKS 
(
ID NUMBER PRIMARY KEY,
DBS_BLOCK_ID NUMBER,
PHEDX_BLOCK_ID NUMBER,
DISCOVERY_DATE NUMBER  NOT NULL,
BLOCK_SIZE_DBS NUMBER,
BLOCK_SIZE_PhEDX NUMBER,
FILE_COUNT_DBS NUMBER,
FILE_COUNT_PhEDX NUMBER,
OPEN_MISMATCH_DBS NUMBER(1),
OPEN_MISMATCH_PhEDX NUMBER(1),
DATASET_ID_DBS NUMBER(38,0),
DATASET_ID_PhEDX NUMBER(38,0)
BLOCK_NAME_DBS VARCHAR2(500 BYTE),
BLOCK_NAME_PHEDX VARCHAR2(1000 BYTE)
);




CREATE SEQUENCE block_sequence;

CREATE OR REPLACE TRIGGER blocks_on_insert
  BEFORE INSERT ON INCONSISTENT_BLOCKS
  FOR EACH ROW
BEGIN
  SELECT block_sequence.nextval
  INTO :new.id
  FROM dual;
END;

CREATE table INCONSISTENT_FILES(
ID NUMBER PRIMARY KEY,
LOGICAL_FILE_NAME varchar2(1000 BYTE) NOT NULL,
BLOCK_ID_DBS NUMBER,
BLOCK_ID_PHEDX NUMBER,
FILE_DISCOVERY_DATE NUMBER NOT NULL,

cksum_dbs VARCHAR2(100 BYTE),
cksum_phedx VARCHAR2(1000 BYTE),
adler32_dbs VARCHAR2(100 BYTE),
adler32_phedx VARCHAR2(100 BYTE),
size_dbs NUMBER(38,0),
size_phedx NUMBER(38,0),

CKSUM_RESULT NUMBER(1),
adler32_RESULT NUMBER(1),
SIZE_RESULT NUMBER(1)
);

CREATE SEQUENCE file_sequence;

CREATE OR REPLACE TRIGGER files_on_insert
  BEFORE INSERT ON INCONSISTENT_FILES
  FOR EACH ROW
BEGIN
  SELECT file_sequence.nextval
  INTO :new.id
  FROM dual;
END;


create table invalid_dbs_blocks
(
block_id number primary key not null,
total_files number not null ,
total_invalid_Files number not null,
is_block_invalid number(1),
insert_date number
);


