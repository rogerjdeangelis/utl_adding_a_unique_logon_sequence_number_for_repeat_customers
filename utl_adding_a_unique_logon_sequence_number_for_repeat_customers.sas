Adding a unique logon sequence number for repeat customers

Same result WPS/SAS

github
https://tinyurl.com/ycn6y7c6
https://github.com/rogerjdeangelis/utl_adding_a_unique_logon_sequence_number_for_repeat_customers

see
https://tinyurl.com/ycc92wyv
https://communities.sas.com/t5/Base-SAS-Programming/Generating-Unique-Random-Values-by-Group/m-p/461233


INPUT
=====

Previous customers

WORK.HAV1ST total obs=10

 ID    FIRSTNAME    REPEAT_NAME

  1    David        David_0001
  2    David        David_0002
  3    David        David_0003

  4    Elizabeth    Elizabeth_0001

  5    Jane         Jane_0001
  6    Jane         Jane_0002

  7    John         John_0001
  8    John         John_0002

  9    Leonard      Leonard_0001
 10    Susan        Susan_0001


New and repeat customers

WORK.HAV2ND total obs=3

  FIRSTNAME    ID

   David       11    ** repeat add with unique logon number
   Donald      13    ** new
   Jane        12    ** repeat

EXAMPLE OUTPUT

WORK.WANT  total obs=13  (add three)

  FIRSTNAME    ID    REPEAT_NAME

  David         1    David_0001
  David         2    David_0002
  David         3    David_0003

  David        11    David_0004   * repeat customer with unique repeat logon

  Donald       13    Donald_0001  * new customer


PROCESS
=======

data want;
    retain cnt 1;
    set hav1st hav2nd(in=add);
    by firstname;
    if add then repeat_name=cats(firstname,'_',put(cnt,z4.));
    cnt=cnt+1;
    if last.firstname then cnt=1;
    drop cnt seq;
run;quit;


OUTPUT
======

WORK.WANT total obs=13

 ID  FIRSTNAME       REPEAT_NAME

  1  David           David_0001
  2  David           David_0002
  3  David           David_0003
 11  David           David_0004     ** repeat

 13  Donald          Donald_0001    ** added

  4  Elizabeth       Elizabeth_0001

  5  Jane            Jane_0001
  6  Jane            Jane_0002      ** repeat
 12  Jane            Jane_0003

  7  John            John_0001
  8  John            John_0002

  9  Leonard         Leonard_0001

 10  Susan           Susan_0001

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

data hav1st;
   retain id seq 1;
   informat firstName $16.;
   input Id FirstName;
   if lag(firstname)=firstname then seq=seq+1;
   else seq=1;
   repeat_name=cats(firstname,'_',put(seq,z4.));
   drop seq;
cards4;
1 David
2 David
3 David
4 Elizabeth
5 Jane
6 Jane
7 John
8 John
9 Leonard
10 Susan
;;;;
run;quit;

*_        ______  ____
\ \      / /  _ \/ ___|
 \ \ /\ / /| |_) \___ \
  \ V  V / |  __/ ___) |
   \_/\_/  |_|   |____/

;

%utl_submit_wps64('
libname wrk sas7bdat "%sysfunc(pathname(work))";
data wrk.want;
    retain cnt 1;
    set wrk.hav1st wrk.hav2nd(in=add);
    by firstname;
    if add then repeat_name=cats(firstname,"_",put(cnt,z4.));
    cnt=cnt+1;
    if last.firstname then cnt=1;
    drop cnt seq;
run;quit;
');

