set serveroutput on;

Create or REPLACE Procedure Consistency_verification IS
BEGIN

DECLARE

  -- row variable declaration for DBS Block table
 
  rec_dbs  cms_dbs3_prod_part.BLOCKS%ROWTYPE;
  
  -- row variable declaration for PhEDX Block table
  
  rec1_phedx  cms_transfermgmt_part.T_DPS_BLOCK%ROWTYPE;
  
  --consistency consition status variable
  
  is_consistent BOOLEAN;
  should_check_files BOOLEAN;

  counter NUMBER := 0;
  
  --file status information
  status varchar2(40);
  
  
BEGIN
     
     -- Looping through every DBS BLOCK record
     FOR rec_dbs IN (SELECT * FROM cms_dbs3_prod_part.blocks) LOOP
     
      BEGIN
      
      is_consistent := TRUE;
      should_check_files := FALSE;
      
      dbms_output.put_line(rec_dbs.BLOCK_NAME || ' Found in DBS');
  
      SELECT * INTO rec1_phedx
      FROM CMS_TRANSFERMGMT_PART.T_DPS_BLOCK
      WHERE rec_dbs.BLOCK_NAME = cms_transfermgmt_part.T_DPS_BLOCK.NAME;
  
       dbms_output.put_line( rec1_phedx.NAME|| ' Also found in PhEDX');

       CASE
          
          WHEN (rec_dbs.BLOCK_SIZE != rec1_phedx.BYTES AND is_consistent) THEN 
          is_consistent :=FALSE;
          should_check_files := True;

          WHEN (rec_dbs.FILE_COUNT != rec1_phedx.FILES AND is_consistent) THEN 
          is_consistent :=FALSE;
          should_check_files := True;

          WHEN (is_consistent  AND ((rec_dbs.OPEN_FOR_WRITING = 1 AND rec1_phedx.IS_OPEN = 'n') OR (rec_dbs.OPEN_FOR_WRITING = 0 AND rec1_phedx.IS_OPEN = 'y'))) THEN 
          is_consistent := FALSE;
          should_check_files := True;
          
          ELSE NULL;
       END CASE;
       
       IF (should_check_files) THEN
        --procedure to check files
        file_level_verification(rec_dbs.BLOCK_ID,status);
        dbms_output.put_line('Result of Check Files : '|| status);
        
        
        --NOTE: input to file_level_verification_phedx is block name as block IDs will be differnet in DBS and PheEDX .
        
        file_level_verification_phedx(rec_dbs.BLOCK_NAME,status);
        dbms_output.put_line('Result of PhEDX END Check Files : '|| status);
        
        END IF;
     
       IF (NOT is_consistent) THEN
        --dbms_output.put_line(' NOT CONSISTENT');

        insert_inconsistent_block(rec_dbs.BLOCK_ID,rec1_phedx.ID,1);

        counter := counter + 1;
        dbms_output.put_line('Number of inconsistencies '||counter ||' ');

       END IF; 




       -- Handles cases where a DBS block record is not found in PhEDX Block table
       

        EXCEPTION

        when NO_DATA_FOUND THEN
          --dbms_output.put_line(' NOT CONSISTENT');
          counter := counter + 1;
          dbms_output.put_line('Number of inconsistencies '||counter ||' ');
          
          --need to added delete level handling
          dbms_output.put_line('Checking for inavlid state file');
          
          file_level_verification(rec_dbs.BLOCK_ID,status);
          dbms_output.put_line('Result of Check Files : '|| status);
          
          IF (status = ' File invalid') THEN
          
           dbms_output.put_line('Result of Check Files: Files found invalid, not added to inconsistent files db');
        
          END IF;
         
          insert_inconsistent_block(10,10,0);
        

          CONTINUE;
       
       END;
       
    end loop;

  
END;

END;
