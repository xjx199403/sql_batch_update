DECLARE
cursor v_rowid_cursor is
select rowid from your_table 
order by rowid; --rowid排序，提高效率
  TYPE rowid_table_type IS TABLE OF ROWID;
  v_rowid_table rowid_table_type; 
BEGIN
  -- 查询需要更新的数据的ROWID，并存储到l_rowids中
  -- 定义更新的批次大小
  -- 根据实际情况调整批次大小，以避免过多的内存消耗和锁竞争
  -- 这里设置为1000行作为一个批次
  
  
    open v_rowid_cursor; --打开rowids游标
    loop 
        exit when v_rowid_cursor%notfound;
        --fetch每次取10000，直到取完
        fetch v_rowid_cursor bulk collect into v_rowid_table limit 10000;
        exit when v_rowid_table.count = 0;
        -- 使用FORALL语句更新批次数据 forall可以将数据从j到 count一次性批量执行
        begin
        FORALL j IN 1..v_rowid_table.COUNT
            -- j 这个变量必须要作为数组的下标使用，
          UPDATE your_table SET a = null WHERE ROWID = v_rowid_table(j);
        end;
        -- 提交更新
        COMMIT;
  END LOOP;
END;
