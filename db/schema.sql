DROP TABLE IF EXISTS VwGPManufacturingOrderProcesses;
CREATE TABLE VwGPManufacturingOrderProcesses (
       mo_id 	       varchar(31) NOT NULL,
       sequence_id     char(11) NOT NULL,
       parallel_seq_id char(11) NULL,
       next_seq_id     char(11) NULL,
       routing_description char(101) NULL,
       wc_id 	       char(11) NULL,
       wc_description  char(31) NULL,
       operation_id    char(7) NULL,
       machine_id      char(11) NOT NULL,
       setup_hrs       numeric(19, 5) NULL,
       machine_hrs     numeric(19, 5) NULL,
       run_hrs	       numeric(19, 5) NULL,
       labor_hrs       numeric(19, 5) NULL,
       cycle_hrs       numeric(19, 5) NULL,
       notes	       text NULL,
       closed_date     datetime NULL,
       closed_by       char(31) NULL,
       done_flag       tinyint
);

CREATE INDEX gpmop_i1 ON VwGPManufacturingOrderProcesses (mo_id DESC);
CREATE INDEX gpmop_i2 ON VwGPManufacturingOrderProcesses (wc_id DESC);

DROP TABLE IF EXISTS VwGPManufacturingOrderTransactions;
CREATE TABLE VwGPManufacturingOrderTransactions (
     eid       	            char(15) NOT NULL,
     last_name		    char(21) NULL,
     first_name		    char(15) NULL,
     datatype_id	    smallint NOT NULL,
     mo_id		    char(31) NOT NULL,
     job_id		    char(31) NULL,
     item_id		    char(31) NULL,
     item_description	    char(101) NULL,
     sequence_id	    char(11) NOT NULL,
     description	    char(101) NULL,
     labor_code		    char(11) NOT NULL,
     start_date		    datetime NOT NULL,
     start_time		    datetime NOT NULL,
     finish_date	    datetime NOT NULL,
     finish_time	    datetime NOT NULL,
     LABCODEDESC_I	    char(31) NOT NULL,
     LABCODEPAYCODESEL_I    smallint NOT NULL,
     elapsed_hrs	    numeric(19,5) NOT NULL,
     complete_qty	    numeric(19,5) NOT NULL,
     reject_qty		    numeric(19,5) NOT NULL,
     change_date	    datetime NOT NULL,
     user_id		    char(15) NOT NULL,
     labor_cost		    numeric(19,5) NOT NULL,
     setup_flag		    tinyint NOT NULL,
     cb_flag		    tinyint NOT NULL,
     POSTABLE_I		    tinyint NOT NULL,
     MFGNOTEINDEX_I   numeric(19,5) NOT NULL,
     fixed_ohead_cost	    numeric(19,5) NOT NULL,
     variable_ohead_cost    numeric(19,5) NOT NULL,
     DEX_ROW_ID		    int NOT NULL
);

CREATE INDEX gpmot_i1 ON VwGPManufacturingOrderTransactions (eid DESC);
CREATE INDEX gpmot_i2 ON VwGPManufacturingOrderTransactions (mo_id DESC);
CREATE INDEX gpmot_i3 ON VwGPManufacturingOrderTransactions (item_id DESC);

DROP TABLE IF EXISTS VwGPManufacturingOrders;
CREATE TABLE VwGPManufacturingOrders (
     mo_id               varchar(31) NOT NULL,
     job_id	         char(31) NOT NULL,
     mo_type		 smallint NOT NULL,
     item_id		 char(31) NOT NULL,
     item_description	 char(101) NULL,
     bom_id		 char(15) NOT NULL,
     bom_rev		 char(51) NOT NULL,
     bom_type		 smallint NOT NULL,
     routing_id		 char(31) NOT NULL,
     routing_rev	 char(51) NOT NULL,
     drawing_id		 char(31) NULL,
     drawing_rev	 varchar(10) NULL,
     drawing_description varchar(40) NULL,
     end_qty		 numeric(19,5) NOT NULL,
     start_qty		 numeric(19,5) NOT NULL,
     start_date		 datetime NOT NULL,
     end_date		 datetime NOT NULL,
     uom_id		 char(11) NULL,
     standard_qty	 numeric(19,5) NULL,
     shipping_uom	 smallint NULL
);

CREATE INDEX gpmo_i1 ON VwGPManufacturingOrders (mo_id DESC);
CREATE INDEX gpmo_i2 ON VwGPManufacturingOrders (item_id DESC);
CREATE INDEX gpmo_i3 ON VwGPManufacturingOrders (job_id DESC);

DROP TABLE IF EXISTS manufacturing_schedule;
CREATE TABLE manufacturing_schedule (
       sid             int NOT NULL,
       wc_id 	       char(11) NOT NULL,
       mo_id           varchar(31) NOT NULL,
       mo_op_id        varchar(31) NOT NULL,
       employees_sid   int NULL,
       quantity        int NULL,
       start_date      smalldatetime NULL,
       due_date        smalldatetime NULL,
       setup_flag      int NULL,
       
       create_sid       int NULL,
       create_date      smalldatetime NULL,
       change_sid       int NULL,
       change_date      smalldatetime NULL,
       change_count     int NULL,
       delete_sid       int NULL,
       delete_date      smalldatetime NULL
);

CREATE UNIQUE INDEX ms_i1 ON manufacturing_schedule (sid DESC);
CREATE INDEX ms_i2 ON manufacturing_schedule (mo_id, mo_op_id DESC);
CREATE INDEX ms_i3 ON manufacturing_schedule (wc_id DESC);

DROP TABLE IF EXISTS manufacturing_tools_bot;
CREATE TABLE manufacturing_tools_bot (
       sid              int NOT NULL,
       mo_id            varchar(31) NOT NULL,
       mo_op_id         varchar(31) NOT NULL,
       bot_rev          varchar(31) NULL,
       bot_rev_date     smalldatetime NULL,
       
       create_sid       int NULL,
       create_date      smalldatetime NULL,
       change_sid       int NULL,
       change_date      smalldatetime NULL,
       change_count     int NULL,
       delete_sid       int NULL,
       delete_date      smalldatetime NULL
);

CREATE UNIQUE INDEX mtb_i1 ON manufacturing_tools_bot (sid DESC);
CREATE INDEX mtb_i2 ON manufacturing_tools_bot (mo_id, mo_op_id DESC);

DROP TABLE IF EXISTS manufacturing_tool_details;
CREATE TABLE manufacturing_tool_details (
       sid              int NOT NULL,
       manufacturing_tools_bot_sid  int NOT NULL,
       tool_no          varchar(31) NOT NULL,
       tool_item_id     varchar(31) NOT NULL,
       instance_id      int NOT NULL,
       tool_id		varchar(31) NOT NULL,
       tool_description varchar(256) NULL,
       tool_type        varchar(31) NULL,
       tool_length_min  float NOT NULL,
       insert_item_id   varchar(31) NULL,
       insert_id        varchar(31) NULL,
       holder_item_id   varchar(31) NULL,
       holder_id        varchar(31) NULL,
       max_depth_cut    float NULL,
       diameter_cutting float NULL,

       create_sid       int NULL,
       create_date      smalldatetime NULL,
       change_sid       int NULL,
       change_date      smalldatetime NULL,
       change_count     int NULL,
       delete_sid       int NULL,
       delete_date      smalldatetime NULL
);

CREATE UNIQUE INDEX mtd_i1 ON manufacturing_tool_details (sid DESC);
CREATE INDEX mtd_i2 ON manufacturing_tool_details (manufacturing_tools_bot_sid DESC);
CREATE INDEX mtd_i3 ON manufacturing_tool_details (tool_no DESC);
