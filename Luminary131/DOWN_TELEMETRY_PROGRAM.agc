### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	DOWN_TELEMETRY_PROGRAM.agc
## Purpose:	A section of Luminary 1C, revision 131.
##		It is part of the source code for the Lunar Module's (LM)
##		Apollo Guidance Computer (AGC) for Apollo 13.
##		This file is intended to be a faithful transcription, except
##		that the code format has been changed to conform to the
##		requirements of the yaYUL assembler rather than the
##		original YUL assembler.
## Reference:	pp. 987-998 of 1729.pdf.
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo/index.html
## Mod history:	05/29/03 RSB.	Began transcribing.
##		05/14/05 RSB	Corrected website reference above.
##		2010-08-24 JL	Fixed page 995 number.
##		2010-10-25 JL	Indentation fixes.

## Page 987
# PROGRAM NAME -- DOWN TELEMETRY PROGRAM
# MOD NO. -- 0		TO COMPLETELY REWRITE THE DOWN TELEMETRY PROGRAM AND DOWNLINK ERASABLE DUMP PROGRAM FOR THE
#			PURPOSE OF SAVING APPROXIMATELY 150 WORDS OF CORE STORAGE.
#			THIS CHANGE REQUIRES AN ENTIRELY NEW METHOD OF SPECIFYING DOWNLINK LISTS.  REFER TO DOWNLINK
#			LISTS LOG SECTION FOR MORE DETAILS.  HOWEVER THIS CHANGES WILL NOT AFFECT THE GROUND PROCESSING
#			OF DOWN TELEMETRY DATA.
# MOD BY -- KILROY, SMITH, DEWITT
# DATE -- 02 OCT 67
# AUTHORS -- KILROY, SMITH, DWWITT, DEWOLF, FAGIN
# LOG SECTION -- DOWN-TELEMETRY PROGRAM
#
# FUNCTIONAL DESCRIPTION -- THIS ROUTINE IS INITIATED BY TELEMETRY END
#	PULSE FROM THE DOWNLINK TELEMETRY CONVERTER.  THIS PULSE OCCURS
#	AT 50 TIMES PER SEC (EVERY 20 MS) THEREFORE DODOWNTM IS
#	EXECUTED AT THESE RATES.  THIS ROUTINE SELECTS THE APPROPRIATE
#	AGC DATA TO BE TRANSMITTED DOWNLINK AND LOADS IT INTO OUTPUT
#	CHANNELS 34 AND 35.  THE INFORMATION IS THEN GATED OUT FROM THE
#	LGC IN SERIAL FASHION.
#
#	THIS PROGRAM IS CODED FOR A 2 SECOND DOWNLIST.  SINCE DOWNRUPTS
#	OCCUR EVERY 20 MS AND 2 AGC COMPUTER WORDS CAN BE PLACED IN
#	CHANNELS 34 AND 35 DURING EACH DOWNRUPT THE PROGRAM IS CAPABLE
# 	OF SENDING 200 AGC WORDS EVERY 2 SECONDS.
#
# CALLING SEQUENCE -- NONE
#	PROGRAM IS ENTERED VIA TCF DODOWNTM WHICH IS EXECUTED AS A
#	RESULT OF A DOWNRUPT.  CONTROL IS RETURNED VIA TCF RESUME WHICH
#	IN EFFECT IS A RESUME.
#
# SUBROUTINES CALLED -- NONE
#
# NORMAL EXIT MODE -- TCF RESUME
#
# ALARM OR ABORT EXIT MODE -- NONE
#
# RESTART PROTECTION:
#	ON A FRESH START AND RESTART THE `STARTSUB' SUBROUTINE WILL INITIALIZE THE DOWNLIST POINTER (ACTUALLY
#	DNTMGOTO) TO THE BEGINNING OF THE CURRENT DOWNLIST (I.E., CURRENT CONTENTS OF DNLSTADR).  THIS HAS THE
#	EFFECT OF IGNORING THE REMAINDER OF THE DOWNLIST WHICH THE DOWN-TELEMETRY PROGRAM WAS WORKING ON WHEN
#	THE RESTART (OR FRESH START) OCCURRED AND RESUME DOWN TELEMETRY FROM THE BEGINNING OF THE CURRENT
#	DOWNLIST.
#
#	ALSO OF INTEREST IS THE FACT THAT ON A RESTART THE AGC WILL ZERO DOWNLINK CHANNELS 13, 34 AND 35.
#
# DOWNLINK LIST SELECTION:
#	THE APPROPRIATE DOWNLINK LISTS ARE SELECTED BY THE FOLLOWING:
#	1.	FRESH START
#	2.	V37EXXE WHERE XX = THE MAJOR MODE BEING SELECTED.
#	3.	UPDATE PROGRAM (P27)
#	4.	NON-V37 SELECTABLE TYPE PROGRAMS (E.G., AGS INITIALIZATION (SUNDANCE, LUMINARY) AND P61-P62
#		TRANSITIONS (COLOSSUS) ETC.).
#
# DOWNLINK LIST RULES AND LIMITATIONS:
#	READ SECTION(S) WHICH FOLLOW `DEBRIS' WRITEUP.
#
# OUTPUT -- EVERY 2 SECONDS 100 DOUBLE PRECISION WORDS (I.E., 200 LGC
#	COMPUTER WORDS) ARE TRANSMITTED VIA DOWNLINK.
#
# ERASABLE INITIALIZATION REQUIRED -- NONE
#	`DNTMGOTO' AND `DNLSTADR' ARE INITIALIZED BY THE FRESH START PROGRAM.
#
# DEBRIS (ERASABLE LOCATIONS DESTROYED BY THIS PROGRAM) --
#	LDATALST, DNTMBUFF TO DNTMBUFF +21D, TMINDEX, DNQ.
## Page 988
# (No source on this page of the original assembly listing.)

## Page 989
# DODOWNTM IS ENTERED EVERY 20 MS BY AN INTERRUPT TRIGGERED BY THE
# RECEIPT OF AN ENDPULSE FROM THE SPACECRAFT TELEMETRY PROGRAMMER.
#
# NOTES REGARDING DOWNLINK LISTS ASSOCIATED WITH THIS PROGRAM:
# 1.	DOWNLISTS.  DOWNLISTS MUST BE COMPILED IN THE SAME BANK AS THE
#	DOWN-TELEMETRY PROGRAM.  THIS IS DONE FOR EASE OF CODING, FASTER
#	EXECUTION.
# 2.	EACH DOWNLINK LIST CONSISTES OF A CONTROL LIST AND A NUMBER OF
#	SUBLISTS.
# 3.	A SUBLIST REFERS TO A SNAPSHOT OR DATA COMMON TO THE SAME OR OTHER
#	DOWNLINK LISTS.  ANY SUBLIST CONTAINING COMMON DATA NEEDS TO BE
#	CODED ONLY ONCE FOR THE APPLICABLE DOWNLINK LISTS.
# 4.	SNAPSHOT SUBLISTS REFER SPECIFICALLY TO HOMOGENEOUS DATA WHICH MUST BE
#	SAVED IN A BUFFER DURING ONE DOWNRUPT.
# 5.	THE 1DNADR FOR THE 1ST WORD OF SNAPSHOT DATA IS FOUND AT THE END
#	OF EACH SNAPSHOT SUBLIST, SINCE THE PROGRAM CODING SENDS THIS DP WORD
#	IMMEDIATELY AFTER STORING THE OTHERS IN THE SNAPSHOT BUFFER.
# 6.	ALL LISTS ARE COMBINATIONS OF CODED ERASABLE ADDRESS CONSTANTS
#	CREATED FOR THE DOWNLIST PROGRAM.
#	A.	1DNADR			1-WORD DOWNLIST ADDRESS.
#		SAME AS ECADR, BUT USED WHEN THE WORD ADDRESSED IS THE LEFT
#		HALF OF A DOUBLE-PRECISION WORD FOR DOWN TELEMETRY.
#	B.	2DNADR - 6DNADR		N-WORD DOWNLIST ADDRESS, N = 2 - 6.
#		SAME AS 1DNADR, BUT WTIH THE 4 UNUSED BITS OF THE ECADR FORMAT
#		FILLED IN WITH 0001-0101.  USED TO POINT TO A LIST OF N DOUBLE-
#		PRECISION WORDS, STORED CONSECUTIVELY, FOR DOWN TELEMETRY.
#	C.	DNCHAN			DOWNLIST CHANNEL ADDRESS.
#		SAME AS 1DNADR, BUT WITH PREFIX BITS 0111.  USED TO POINT TO
#		A PAIR OF CHANNELS FOR DOWN TELEMETRY.
#	D.	DNPTR			DOWN-TELEMETRY SUBLIST POINTER.
#		SAME AS CAF BUT TAGGES AS A CONSTANT.  USED IN CONTROL LIST TO POINT TO A SUBLIST.
#		CAUTION --- A DNPTR CANNOT BE USED IN A SUBLIST.
# 7.	THE WORD ORDER CODE IS SET TO ZERO AT THE BEGINNING OF EACH DOWNLIST (I.E., CONTROL LIST) AND WHEN
#	A `1DNADR TIME2' IS DETECTED IN THE CONTROL LIST (ONLY).
# 8.	IN THE SNAPSHOT SUBLIST ONLY, THE DNADR'S CANNOT POINT TO THE FIRST WORD OF ANY EBANK.
#
# DOWNLIST LIST RESTRICTIONS:
# (THE FOLLOWING POINTS MAY BE LISTED ELSEWHERE BUT ARE LISTED HERE SO IT IS CLEAR THAT THESE THINGS CANNOT BE
# DONE)
# 1.	SNAPSHOT DOWNLIST:
#	(A) CANNOT CONTAIN THE FOLLOWING ECADRS (I.E., 1DNADR'S): Q, 400, 1000, 1400, 2000, 2400, 3000, 3400.
#	(B) CAN CONTAIN ONLY 1DNADR'S
# 2.	ALL DOWNLINKED DATA (EXCEPT CHANNELS) IS PICKED UP BY A DCA SO DOWNLINK LISTS CANNOT CONTAIN THE
#	EQUIVALENT OF THE FOLLOWING ECADRS (I.E., IDNADRS): 377, 777, 1377, 1777, 2377, 2777, 3377, 3777.
# 	(NOTE: TE TERM `EQUIVALENT' MEANT THAT THE IDNADR TO 6DNADR WILL BE PROCESSED LIKE 1 TO 6 ECADRS)
# 3.	CONTROL LISTS AND SUBLISTS CANNOT HAVE ENTRIES = OCTAL 00000 OR OCTAL 77777
## Page 990
# 4.	THE `1DNADR TIME2' WHICH WILL CAUSE THE DOWNLINT PROGRAM TO SET THE WORDER CODE TO 3 MUST APPEAR IN THE
#	CONTROL SECTION OF THE DOWNLIST.
# 5.	`DNCHAN 0' CANNOT BE USED.
# 6.	`DNPTR 0' CANNOT BE USED.
# 7.	DNPTR CANNOT APPEAR IN A SUBLIST.
#
# EBANK SETTINGS
#	IN THE PROCESS OF SETTING THE EBANK (WHEN PICKING UP DOWNLINK DATA) THE DOWN TELEMETRY PROGRAM PUTS
#	`GARBAGE' INTO BITS15-12 OF EBANK.  HUGH BLAIR-SMITH WARNS US THAT BITS15-12 OF EBANK MAY BECOME
#	SIGNIFICANT SOMEDAY IN THE FUTURE.  IF/WHEN THAT HAPPENS, THE PROGRAM SHOULD INSURE (BY MASKING ETC.)
#	THAT BITS 15-12 OF EBANK ARE ZERO.
#
# INITIALIZATION REQUIRED -- TO INTERRUPT CURRENT LIST AND START A NEW ONE.
#	1. ADRES OF DOWNLINK LIST INTO DNLSTADR
#	2. NEGONE INTO SUBLIST
#	3. NEGONE INTO DNECADR

		BANK	22
		SETLOC	DOWNTELM
		BANK

		EBANK=	DNTMBUFF
		COUNT*	$$/DPROG
DODOWNTM	TS	BANKRUPT
		EXTEND
		QXCH	QRUPT		# SAVE Q
		CA	BIT7		# AT THE BEGINNING OF THE LIST THE WORD
		EXTEND			# ORDER BIT WILL BE SET BACK TO ZERO.
		RAND	CHAN13
		CCS	A
		TC	DNTMGOTO
		TC	C13STALL
		CA	BIT7
		EXTEND			# SET WORD ORDER BIT TO 1 ONLY IF IT
		WOR	CHAN13		# ALREADY ISN'T
		TC	DNTMGOTO	# GOTO APPROPRIATE PHASE OF PROGRAM

		SETLOC	DOWNTELM
		BANK

DNPHASE1	CA	NEGONE		# INITIALIZE ALL CONTROL WORDS
		TS	SUBLIST		# WORDS TO MINUS ONE
		TS	DNECADR
		CA	LDNPHAS2	# SET DNTMGOTO = 0 ALL SUSEQUENT DOWRUPTS
## Page 991
		TS	DNTMGOTO	# GO TO DNPHASE2
		TCF	NEWLIST
DNPHASE2	CCS	DNECADR		# SENDING OF DATA IN PROGRESS
DODNADR		TC	FETCH2WD	# YES -- THEN FETCH THE NEXT 2 SP WORDS
MINTIME2	-1DNADR	TIME2		# NEGATIVE OF TIME2 1DNADR
		TCF	+1		# (ECADR OF 3776 + 74001 = 77777)

		CCS	SUBLIST		# IS THE SUBLIST IN CONTROL
		TCF	NEXTINSL	# YES
DNADRDCR	OCT	74001		# DNADR COUNT AND ECADR DECREMENTER

CHKLIST		CA	CTLIST
		EXTEND
		BZMF	NEWLIST		# IT WILL BE NEGATIVE AT END OF LIST
		TCF	NEXTINCL
NEWLIST		INDEX	DNLSTCOD
		CA	DNTABLE		# INITIALIZE CTLIST WITH
		TS	CTLIST		#	STARTING ADDRESS OF NEW LIST
		CS	DNLSTCOD
		TCF	SENDID +3
NEXTINCL	INDEX	CTLIST
		CA	0
		CCS	A
		INCR	CTLIST		# SET POINTER TO PICK UP NEXT CTLIST WORD
		TCF	+4		# ON NEXT ENTRY TO PROG.  (A SHOULD NOT =0)
		XCH	CTLIST		# SET CTLIST TO NEGATIVE AND PLACE(CODING)
		COM			# UNCOMPLEMENTED DNADR INTO A.    (FOR LA)
		XCH	CTLIST		#                                 (ST IN )
 +4		INCR	A		#                                 (CTLIST)
 		TS	DNECADR		# SAVE DNADR
		AD	MINTIME2	# TEST FOR TIME2 (NEG. OF ECADR)
		CCS	A
		TCF	SETWO +1	# DON'T SET WORD ORDER CODE
MINB1314	OCT	47777		# MINUS BIT 13 AND 14 (CAN'T GET HERE)
		TCF	SETWO +1	# DON'T SET WORD ORDER CODE
SETWO		TC	WOZERO		# GO SET WORD ORDER CODE TO ZERO.
 +1		CA	DNECADR		# RELOAD A WITH THE DNADR.
 +2		AD	MINB1314	# IS THIS A REGULAR DNADR?
 		EXTEND
		BZMF	FETCH2WD	# YES.  (A MUST NEVER BE ZERO)
		AD	MINB12		# NO.  IS IT A POINTER (DNPTR) OR A
		EXTEND			#	CHANNEL(DNCHAN)
		BZMF	DODNPTR		# IT'S A POINTER.  (A MUST NEVER BE ZERO)

DODNCHAN	TC	6		# (EXECUTED AS EXTEND)  IT'S A CHANNEL
		INDEX	DNECADR
		INDEX	0 -4000		# (EXECUTED AS READ)
		TS	L
		TC	6		# (EXECUTED AS EXTEND)
		INDEX	DNECADR
## Page 992
		INDEX	0 -4001		# (EXECUTED AS READ)
		TS	DNECADR		# SET DNECADR
		CA	NEGONE		#	TO MINUS
		XCH	DNECADR		#		WHILE PRESERVING A.
		TCF	DNTMEXIT	# GO SEND CHANNELS

WOZERO		EXTEND
		QXCH	C13QSAV
		LXCH	RUPTREG1
		TC	C13STALL

		LXCH	RUPTREG1
		CS	BIT7
		EXTEND
		WAND	CHAN13		# SET WORD ORDER CODE TO ZERO
		TC	C13QSAV

DODNPTR		INDEX	DNECADR		# DNECADR CONTAINS ADRES OF SUBLIST
		0	0		# CLEAR AND ADD LIST ENTRY INTO A.
		CCS	A		# IS THIS A SNAPSHOT SUBLIST
		CA	DNECADR		# NO, IT IS A REGULAR SUBLIST.
		TCF	DOSUBLST	# A MUST NOT BE ZERO.

		XCH	DNECADR		# YES.  IT IS A SNAPSHOT SUBLIST.
		TS	SUBLIST		# C(DNECADR) INTO SUBLIST
		CAF	ZERO		#	A    INTO     A
		XCH	TMINDEX		# (NOTE:  TMINDEX = DNECADR)

# THE FOLLOWING CODING (FROM SNAPLOOP TO SNAPEND) IS FOR THE PURPOSE OF TAKING A SNAPSHOT OF 12 DP REGISTERS.
# THIS IS DONE BY SAVING 11 DP REGISTERS IN DNTMBUFF AND SENDING THE FIRST DP WORD IMMEDIATELY.
# THE SNAPSHOT PROCESSING IS THE MOST TIME CONSUMING AND THEREFORE THE CODING AND LIST STRUCTURE WERE DESIGNED
# TO MINIMIZE TIME.  THE TIME OPTIMIZATION RESULTS IN RULES UNIQUE TO THE SNAPSHOT PORTION OF THE DOWNLIST.
# THESE RULES ARE ......
#	1.	ONLY 1DNADR'S CAN APPEAR IN THE SNAPSHOT SUBLIST
#	2.	THE 1DNADR'S CANNOT REFER TO THE FIRST LOCATION IN ANY BANK.

SNAPLOOP	TS	EBANK		# SET EBANK
		MASK	LOW8		# ISOLATE RELATIVE ADDRESS
		EXTEND
		INDEX	A
		EBANK=	1401
		DCA	1401		# PICK UP 2 SNAPSHOT WORDS.
		EBANK=	DNTMBUFF
		INDEX	TMINDEX
		DXCH	DNTMBUFF	# STORE 2 SNAPSHOT WORDS IN BUFFER
		INCR	TMINDEX		# SET BUFFER INDEX FOR NEXT 2 WORDS.
		INCR	TMINDEX
SNAPAGN		INCR	SUBLIST		# SET POINTER TO NEXT 2 WORDS OF SNAPSHOT
## Page 993
		INDEX	SUBLIST
		0	0		# = CA SSSS (SSSS = NEXT ENTRY IN SUBLIST)
		CCS	A		# TEST FOR LAST TWO WORDS OF SNAPSHOT.
		TCF	SNAPLOOP	# NOT LAST TWO.
LDNPHAS2	GENADR	DNPHASE2
		TS	SUBLIST		# YES, LAST.  SAVE A.
		CA	NEGONE		# SET DNECADR AND
		TS	DNECADR		#	SUBLIST POINTERS
		XCH	SUBLIST		#		TO NEGATIVE VALUES
		TS	EBANK
		MASK	LOW8
		EXTEND
		INDEX	A
		EBANK=	1401
		DCA	1401		# PICK UP FIRST 2 WORDS OF SNAPSHOT.
		EBANK=	DNTMBUFF
SNAPEND		TCF	DNTMEXIT	# NOW TO SEND THEM.

FETCH2WD	CA	DNECADR
		TS	EBANK		# SET EBANK
		MASK	LOW8		# ISOLATE RELATIVE ADDRESS
		TS	L
		CA	DNADRDCR	# DECREMENT COUNT AND ECADR
		ADS	DNECADR
		EXTEND
		INDEX	L
		EBANK=	1400
		DCA	1400		# PICK UP 2 DATA WORDS
		EBANK=	DNTMBUFF
		TCF	DNTMEXIT	# NOW GO SEND THEM.

DOSUBLST	TS	SUBLIST		# SET SUBLIST POINTER
NEXTINSL	INDEX	SUBLIST
		0	0		# = CA SSSS (SSSS = NEXT ENTRY IN SUBLIST)
		CCS	A		# IS IT THE END OF THE SUBLIST
		INCR	SUBLIST		# NO --
		TCF	+4
		TS	SUBLIST		# SAVE A.
		CA	NEGONE		# SET SUBLIST TO MINUS
		XCH	SUBLIST		# RETRIEVE A.
 +4		INCR	A
 		TS	DNECADR		# SAVE DNADR
		TCF	SETWO +2	# GO USE COMMON CODING (PROLEMS WOULD
					# OCCUR IF THE PROGRAM ENCOUNTERED A
					# DNPTR NOW)

DNTMEXIT	EXTEND			# DOWN-TELEMETRY EXIT
		WRITE	DNTM1		# TO SEND A + L TO CHANNELS 34 + 35
		CA	L		# RESPECTIVELY
TMEXITL		EXTEND
## Page 994
		WRITE	DNTM2
TMRESUME	TCF	RESUME		# EXIT TELEMTRY PROGRAM VIA RESUME.

MINB12		EQUALS	-1/8
DNECADR		EQUALS	TMINDEX
CTLIST		EQUALS	LDATALST
SUBLIST		EQUALS 	DNQ

# MOD BY -- DENSMORE -- JUNE 1969 -- ELIMINATE ERASABLE DUMP COUNT

## Page 995
# SUBROUTINE NAME -- DNDUMP
#
# FUNCTIONAL DESCRIPTION -- TO SEND (DUMP) ALL 8 BANKS OF ERASABLE STORAGE TWICE.  BANKS ARE SENT ONE AT A TIME
#	EACH BANK IS PRECEDED BY AN ID WORD, SYNCH BITS, ECADR AND TIME1 FOLLOWED BY THE 256D WORDS OF EACH
#	EBANK.  EBANKS ARE DUMPED IN ORDER (I.E., EBANK 0 FIRST, THEN EBANK1 ETC.)
#
# CALLING SEQUENCE -- THE GROUND OR ASTRONAUT BY KEYING V74E CAN INITIALIZE THE DUMP.
#	AFTER KEYING IN V74E THE CURRENT DOWNLIST WILL BE IMMEDIATELY TERMINATED AND THE DOWNLINK ERASABLE DUMP
#	WILL BEGIN.
#
#	ONCE INITITIATED THE DOWNLINK ERASABLE DUMP CAN BE TERMINATED (AND INTERRUPTED DOWNLIST REINSTATED) ONLY
#	BY THE FOLLOWING:
#
#	1.	A FRESH START
#	2.	COMPLETION OF BOTH COMPLETE DUMPS
#	3.	AND INVOLUNTARILY BY A RESTART.
#
# NORMAL EXIT MODE -- TCF DNPHASE1
#
# ALARM OR ABORT MODE -- NONE
#
# *SUBROUTINES CALLED -- NONE
#
# ERASABLE INITIALIZATION REQUIRED --
#	NONE
#
# DEBRIS -- DUMPLOC, DUMPSW, DNTMGOTO, EBANK, AND CENTRAL REGISTERS
#
# TIMING --	TIME (IN SECS) = ((NO.DUMPS)*(NO.EBANKS)*(WDSPEREBANK + NO.IDWDS)) / NO.WDSPERSEC
#		TIME (IN SECS) =  (   4    )*(    8    )*(    256     +     4   )  /     100
#		THUS TIME (IN SECS TO SEND DUMP OF ERASABLE 4 TIMES VIA DOWNLINK) = 83.2 SECONDS
#
# STRUCTURE OF ONE EBANK AS IT IS SENT BY DOWNLINK PROGRAM --
#	(REMINDER -- THIS ONLY DESCRIBES ONE OF THE 8 EBANKS X 4 (DUMPS) = 32 EBANKS WHICH WILL BE SENT BY DNDUMP)
#
#	DOWNLIST				W
#	  WORD	TAKEN FROM CONTENTS OF	EXAMPLE	O	COMMENTS
#	    1	ERASID			 0177X	0	DOWNLIST I.D. FOR DOWNLINK ERASABLE DUMP (X=7 CSM, 6 LM)
#	    2	LOWIDCOD		 77340 	1	DOWNLINK SYNCH BITS.  (SAME ONE USED IN ALL OTHER DOWNLISTS)
#	    3	DUMPLOC			 13400	1	(SEE NOTES ON DUMPLOC) 1 = 3RD ERAS DUMP, 3400=ECADR OF 5TH WD
#	    4	TIME1			 14120	1	TIME IN CENTISECONDS
#	    5	FIRST WORD OF EBANK X	 03400	1	IN THIS EXAMPLE THIS WORD = CONTENTS OF E7,1400 (ECADR 3400)
#	    6	2ND   WORD OF EBANK X	 00142	1	IN THIS EXAMPLE THIS WORD = CONTENTS OF E7,1401 (ECADR 3401)
#	    7.  3RD   WORD OF EBANK X	 00142	1	IN THIS EXAMPLE THIS WORD = CONTENTS OF E7,1402 (ECADR 3402)
#	    .
#	    .
#	    .
#	 260D	256TH WORD OF EBANK X	 03777	1	IN THIS EXAMPLE THIS WORD = CONTENTS OF E7,1777 (ECADR 3777)
#
# NOTE --	DUMPLOC CONTAINS THE COUNTER AND ECADR FOR EACH WORD BEING SENT.
#		THE BIT STRUCTURE OF DUMPLOC IS FOLLOW --
#						X = NOT USED
#		X ABC EEE RRRRRRRR	      ABC = ERASABLE DUMP COUNTER (I.E. ABC = 0,1,2, OR 3 WHICH MEANS THAT
#						    COMPLETE ERASABLE DUMP NUMBER 1,2,3, OR 4 RESPECTIVELY IS IN PROGRESS)
#					      EEE = EBANK BITS
#					 RRRRRRRR = RELATIVE ADDRESS WITHIN AN EBANK

DNDUMPI		CA	ZERO		# INITIALIZE DOWNLINK
		TS	DUMPLOC		# ERASABLE DUMP
 +2		TC	SENDID		# GO SEND ID AND SYNCH BITS

## Page 996
		CA	LDNDUMP1	# SET DNTMGOTO
		TS	DNTMGOTO	# TO LOCATION FOR NEXT PASS
		CA	TIME1		# PLACE TIME1
		XCH	L		# INTO L
		CA	DUMPLOC		# AND ECADR OF THIS EBANK INTO A
		TCF	DNTMEXIT	# SEND DUMPLOC AND TIME1

LDNDUMP		ADRES	DNDUMP
LDNDUMP1	ADRES	DNDUMP1

DNDUMP		CA	TWO		# INCREMENT ECADR IN DUMPLOC
		ADS	DUMPLOC		# TO NEXT DP WORD TO BE
		MASK	LOW8		# DUMPED AND SAVE IT.
		CCS	A		# IS THIS THE BEGINNING OF A NEW EBANK
		TCF	DNDUMP2		# NO -- THEN CONTINUE DUMPING
		CA	DUMPLOC		# YES -- IS THIS THE END OF THE
		MASK	BIT13		# SECOND COMPLETE ERASABLE DUMP?
		EXTEND
		BZF	DNDUMPI +2	# NO -- GO BACK AND INITIALIZE NEXT BANK
		TCF	DNPHASE1	# YES -- SEND DOWNLIST AGAIN
DNDUMP1		CA	LDNDUMP		# SET DNTMGOTO
		TS	DNTMGOTO	# FOR WORDS 3 TO 256D OF CURRENT EBANK

DNDUMP2		CA	DUMPLOC
		TS	EBANK		# SET EBANK
		MASK	LOW8		# ISOLATE RELATIVE ADDRESS.
		TS	Q		# (NOTE: MASK INSTRUCTION IS USED TO PICK
		CA	NEG0		# UP ERASABLE REGISTERS TO THAT EDITING
		TS	L		# REGISTERS 20-23 WILL NOT BE ALTERED.)
		INDEX	Q
		EBANK=	1400		# PICK UP LOW ORDER REGISTER OF PAIR
		MASK	1401		# OF ERASABLE REGISTERS.
		XCH	L
		INDEX	Q		# PICK UP HIGH ORDER REGISTER OF PAIR
		MASK	1400		# OF ERASABLE REGISTERS.
		EBANK=	DNTMBUFF
		TCF	DNTMEXIT	# GO SEND THEM

SENDID		EXTEND			# ** ENTRANCE USED BY ERASABLE DUMP PROG. **
		QXCH	DNTMGOTO	# SET DNTMGOTO SO NEXT TIME PROG WILL GO
		CAF	ERASID		# TO LOCATION FOLLOWING `TC SENDID'

		TS	L		# ** ENTRANCE USED BY REGULAR DOWNLINK PG **
		TC	WOZERO		# GO SET WORD ORDER CODE TO ZERO
		CAF	LOWIDCOD	# PLACE SPECIAL ID CODE INTO L
		XCH	L		# AND ID BACK INTO A
		TCF	DNTMEXIT	# SEND DOWNLIST ID CODE(S).

