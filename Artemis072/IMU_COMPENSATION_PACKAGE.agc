### FILE="Main.annotation"
# Copyright:	Public domain.
# Filename:	IMU_COMPENSATION_PACKAGE.agc
# Purpose:	Part of the source code for Artemis (i.e., Colossus 3),
#		build 072.  This is for the Command Module's (CM)
#		Apollo Guidance Computer (AGC), we believe for
#		Apollo 15-17.
# Assembler:	yaYUL
# Contact:	Jim Lawton <jim DOT lawton AT gmail DOT com>
# Website:	www.ibiblio.org/apollo/index.html
# Page scans:	www.ibiblio.org/apollo/ScansForConversion/Artemis072/
# Mod history:	2009-08-09 JL	Adapted from corresponding Comanche 055 file.

## Page 308

		SETLOC	IMUCOMP
		BANK
		EBANK=	NBDX

		COUNT*	$$/ICOMP
1/PIPA		CAF	LGCOMP		# SAVE EBANK OF CALLING PROGRAM
		XCH	EBANK
		TS	MODE

		CCS	GCOMPSW		# BYPASS IF GCOMPSW NEGATIVE
		TCF	+3
		TCF	+2
		TCF	IRIG1		# RETURN

		INHINT			# ASSURE COMPLETE COMPENSATION OF DELV'S
					# FOR DOWNLINK.

1/PIPA1		CAF	FOUR		# PIPAZ, PIPAY, PIPAX
 +1		MASK	NEGONE
		TS	BUF +2

		INDEX	BUF +2
		CA	PIPASCF		# (P.P.M.) X 2(-9)
		EXTEND
		INDEX	BUF +2
		MP	DELVX		# (PP) X 2(+14) NOW (PIPA PULSES) X 2(+5)
		TS	Q		# SAVE MAJOR PART

		CA	L		# MINOR PART
		EXTEND
		MP	BIT6		# SCALE 2(+9)	SHIFT RIGHT 9
		INDEX 	BUF +2
		TS	DELVX +1	# FRACTIONAL PIPA PULSES SCALED 2(+14)

		CA	Q		# MAJOR PART
		EXTEND
		MP	BIT6		# SCALE 2(+9)	SHIFT RIGHT 9
		INDEX	BUF +2
		DAS	DELVX		# (PIPAI) + (PIPAI)(SFE)

		INDEX	BUF +2
		CS	PIPABIAS	# (PIPA PULSES)/(CS) X 2(-6)
		EXTEND
		MP	1/PIPADT	# (CS) X 2(+8) NOW (PIPA PULSES) X 2(+2)
		EXTEND
		MP	BIT3		# SCALE 2(+12) SHIFT RIGHT 12
		INDEX	BUF +2
		DAS	DELVX		# (PIPAI) + (PIPAI)(SFE) - (BIAS)(DELTAT)

		CCS	BUF +2		# PIPAZ, PIPAY, PIPAX
		TCF	1/PIPA1 +1
## Page 309
		RELINT
## Page 310

IRIGCOMP	TS	GCOMPSW		# INDICATE COMMANDS 2 PULSES OR LESS.
		TS	BUF		# INDEX COUNTER - IRIGX, IRIGY, IRIGZ

IRIGX		EXTEND
		DCS	DELVX		# (PIPA PULSES) X 2(+14)
		DXCH	MPAC
		CA	ADIAX		# (GYRO PULSES)/(PIPA PULSE) X 2(-3)		*
		TC	GCOMPSUB	# -(ADIAX)(PIPAX)	(GYRO PULSES) X 2(+14)

		EXTEND
		DCS	DELVY		# (PIPA PULSES) X 2(+14)
		DXCH	MPAC
		CS	ADSRAX		# (GYRO PULSES)/(PIPA PULSE) X 2(-3)		*
		TC	GCOMPSUB	# +(ADSRAX)(PIPAY)	(GYRO PULSES) X 2(+14)

#		EXTEND			# ***
#		DCS	DELVZ		# *** (PIPA PULSES) X 2(+14)
#		DXCH	MPAC		# ***
#		CA	ADOAX		# *** (GYRO PULSES)/(PIPA PULSE) X 2(-3)	*
#		TC	GCOMPSUB	# *** -(ADOAX)(PIPAZ)	(GYRO PULSES) X 2(+14)

		CS	NBDX		# (GYRO PULSES)/(CS) X 2(-5)
		TC	DRIFTSUB	# -(NBDX)(DELTAT)	(GYRO PULSES) X 2(+14)

IRIGY		EXTEND
		DCS	DELVY		# (PIPA PULSES) X 2(+14)
		DXCH	MPAC
		CA	ADIAY		# (GYRO PULSES)/(PIPA PULSE) X 2(-3)		*
		TC	GCOMPSUB	# -(ADIAY)(PIPAY)	(GYRO PULSES) X 2(+14)

		EXTEND
		DCS	DELVZ		# (PIPA PULSES) X 2(+14)
		DXCH	MPAC
		CS	ADSRAY		# (GYRO PULSES)/(PIPA PULSE) X 2(-3)		*
		TC	GCOMPSUB	# +(ADSRAY)(PIPAZ)	(GYRO PULSES) X 2(+14)

#		EXTEND			# ***
#		DCS	DELVX		# *** (PIPA PULSES) X 2(+14)
#		DXCH	MPAC		# ***
#		CA	ADOAY		# *** (GYRO PULSES)/(PIPA PULSE) X 2(-3)	*
#		TC	GCOMPSUB	# *** -(ADOAY)(PIPAX)	(GYRO PULSES) X 2(+14)

		CS	NBDY		# (GYRO PULSES)/(CS) X 2(-5)
		TC	DRIFTSUB	# -(NBDY)(DELTAT)	(GYRO PULSES) X 2(+14)

IRIGZ		EXTEND
		DCS	DELVY		# (PIPA PULSES) X 2(-14)
		DXCH	MPAC
		CA	ADSRAZ		# (GYRO PULSES)/(PIPA PULSE) X 2(-3)		*
## Page 311
		TC	GCOMPSUB	# -(ADSRAZ)(PIPAY)	(GYRO PULSES) X 2(+14)

		EXTEND
		DCS	DELVZ		# (PIPA PULSES) X 2(+14)
		DXCH	MPAC
		CA	ADIAZ		# (GYRO PULSES)/(PIPA PULSE) X 2(-3)		*
		TC	GCOMPSUB	# -(ADIAZ)(PIPAZ)	(GYRO PULSES) X 2(+14)

#		EXTEND			# ***
#		DCS	DELVX		# *** (PIPA PULSE) X 2(+14)
#		DXCH	MPAC		# ***
#		CS	ADOAZ		# *** (GYRO PULSES)/(PIPA PULSE) X 2(-3)	*
#		TC	GCOMPSUB	# *** +(ADOAZ)(PIPAX)	(GYRO PULSES) X 2(+14)

		CA	NBDZ		# (GYRO PULSES)/(CS) X 2(-5)
		TC	DRIFTSUB	# +(NBDZ)(DELTAT)	(GYRO PULSES) X 2(+14)

## Page 312
		CCS	GCOMPSW		# ARE GYRO COMMANDS GREATER THAN 2 PULSES
		TCF	+2		# YES
		TCF	IRIG1		# NO

		CA	PRIO21		# HIGHER THAN SERVICER-LESS THAN PRELAUNCH
		TC	NOVAC
		EBANK=	NBDX
		2CADR	1/CHECK

		RELINT
IRIG1		CA	MODE		# SET EBANK FOR RETURN
		TS	EBANK
		TCF	SWRETURN

GCOMPSUB	XCH	MPAC		# ADIA OR ADSRA COEFFICIENT ARRIVES IN A
		EXTEND			# C(MPAC) = (PIPA PULSES) X 2(+14)
		MP	MPAC		# (GYRO PULSES)/(PIPA PULSE) X 2(-3)		*
		DXCH	VBUF		# NOW = (GYRO PULSES) X 2(+11)			*

		CA	MPAC +1		# MINOR PART OF PIPA PULSES
		EXTEND
		MP	MPAC		# ADIA OR ADSRA
		TS	L
		CAF	ZERO
		DAS	VBUF		# NOW = (GYRO PULSES) X 2(+11)			*

		CA	VBUF		# PARTIAL RESULT - MAJOR
		EXTEND
		MP	BIT12		# SCALE 2(+3)	SHIFT RIGHT 3			*
		INDEX	BUF		# RESULT = (GYRO PULSES) X 2(+14)
		DAS	GCOMP		# HI(ADIA)(PIPAI)  OR  HI(ADSRA)(PIPAI)

		CA	VBUF +1		# PARTIAL RESULT - MINOR
		EXTEND
		MP	BIT12		# SCALE 2(+3)	SHIFT RIGHT 3			*
		TS	L
		CAF	ZERO
		INDEX	BUF		# RESULT = (GYRO PULSES) X 2(+14)
		DAS	GCOMP		# (ADIA)(PIPAI)  OR  (ADSRA)(PIPAI)

		TC	Q

## Page 313
DRIFTSUB	EXTEND
		QXCH	BUF +1

		EXTEND			# C(A) = NBD	(GYRO PULSES)/(CS) X 2(-5)
		MP	1/PIPADT	# (CS) X 2(+8)	 NOW (GYRO PULSES) X 2(+3)
		LXCH	MPAC +1		# SAVE FOR FRACTIONAL COMPENSATION
		EXTEND
		MP	BIT4		# SCALE 2(+11)		SHIFT RIGHT 11
		INDEX	BUF
		DAS	GCOMP		# HI(NBD)(DELTAT)	(GYRO PULSES) X 2(+14)

		CA	MPAC +1		# NOW MINOR PART
		EXTEND
		MP	BIT4		# SCALE 2(+11)		SHIFT RIGHT 11
		TS	L
		CAF	ZERO
		INDEX	BUF		# ADD IN FRACTIONAL COMPENSATION
		DAS	GCOMP		# (NBD)(DELTAT)		(GYRO PULSES) X 2(+14)

DRFTSUB2	CAF	TWO		# PIPAX, PIPAY, PIPAZ
		AD	BUF
		XCH	BUF
		INDEX	A
		CCS	GCOMP		# ARE GYRO COMMANDS 1 PULSE OR GREATER
		TCF	+2		# YES
		TC	BUF +1		# NO

		MASK	NEGONE
		CCS	A		# ARE GYRO COMMANDS GREATER THAN 2 PULSES
		TS	GCOMPSW		# YES - SET GCOMPSW POSITIVE
		TC	BUF +1		# NO

## Page 314
1/CHECK		CA	MODECADR
		EXTEND
		BZF	1/GYRO
		TCF	ENDOFJOB

1/GYRO		CAF	FOUR		# PIPAZ, PIPAY, PIPAX
 +1		TS	BUF

		INDEX	BUF		# SCALE GYRO COMMANDS FOR IMUPULSE
		CA	GCOMP +1	# FRACTIONAL PULSES
		EXTEND
		MP	BIT8		# SHIFT RIGHT 7
		INDEX	BUF
		TS	GCOMP +1	# FRACTIONAL PULSES SCALED

		CAF	ZERO		# SET GCOMP = 0 FOR DAS INSTRUCTION
		INDEX	BUF
		XCH	GCOMP		# GYRO PULSES
		EXTEND
		MP	BIT8		# SHIFT RIGHT 7
		INDEX	BUF
		DAS	GCOMP		# ADD THESE TO FRACTIONAL PULSES ABOVE

		CCS	BUF		# PIPAZ, PIPAY, PIPAX
		AD	NEG1
		TCF	1/GYRO +1
LGCOMP		ECADR	GCOMP		# LESS THAN ZERO IMPOSSIBLE

		CAF	LGCOMP
		TC	BANKCALL
		CADR	IMUPULSE	# CALL GYRO TORQUING ROUTINE
		TC	BANKCALL
		CADR	IMUSTALL	# WAIT FOR PULSES TO GET OUT
		TCF	+1

GCOMP1		CAF	FOUR		# PIPAZ, PIPAY, PIPAX
 +1		TS	BUF

		INDEX	BUF		# RESCALE
		CA	GCOMP +1
		EXTEND
		MP	BIT8		# SHIFT MINOR PART LEFT 7 - MAJOR PART = 0
		INDEX	BUF
		LXCH	GCOMP +1	# BITS 8-14 OF MINOR PART WERE = 0

		CCS	BUF		# PIPAZ, PIPAY, PIPAX
		AD	NEG1
		TCF	GCOMP1 +1
OCT75252	OCT	75252		# -15 DEGREES USED BY T4RUPT
		TCF	ENDOFJOB

## Page 315
NBDONLY		CCS	GCOMPSW		# BYPASS IF GCOMPSW NEGATIVE
		TCF	+3
		TCF	+2
		TCF	ENDOFJOB

		INHINT
		CCS	FLAGWRD2
		MASK	DRFTBIT
		EXTEND
		BZF	ENDOFJOB

		CA	TIME1		# (CS) X 2(+14)
		XCH	1/PIPADT	# PREVIOUS TIME
		RELINT
		COM
		AD	1/PIPADT
NBD2		CCS	A		# CALCULATE ELAPSED TIME
		AD	ONE		# NO TIME1 OVERFLOW
		TCF	NBD3		# RESTORE TIME DIFFERENCE AND JUMP
		TCF	+2		# TIME1 OVERFLOW
		TCF	ENDOFJOB	# IF ELAPSED TIME = 0 (DIFFERENCE = -0)

		COM			# CALCULATE ABSOLUTE DIFFERENCE
		AD	POSMAX

NBD3		EXTEND			# C(A) = DELTAT		(CS) X 2(+14)
		MP	BIT10		# SHIFT RIGHT 5
		DXCH	VBUF
		EXTEND
		DCA	VBUF
		DXCH	MPAC		# DELTAT NOW SCALED (CS) X 2(+19)

		CAF	ZERO
		TS	GCOMPSW		# INDICATE COMMANDS 2 PULSES OR LESS
		TS	BUF		# PIPAX, PIPAY, PIPAZ

		CS	NBDX		# (GYRO PULSES)/(CS) X 2(-5)
		TC	FBIASSUB	# -(NBOX)(DELTAT) 	(GYRO PULSES) X 2(+14)

		EXTEND
		DCS	VBUF
		DXCH	MPAC		# DELTAT SCALED (CS) X 2(+19)
		CA	NBDY		# (GYRO PULSES)/(CS) X 2(-5)
		TC	FBIASSUB	# -(NBDY)(DELTAT)	(GYRO PULSES) X 2(+14)

		EXTEND
		DCS	VBUF
		DXCH	MPAC		# DELTAT SCALED (CS) X 2(+19)
		CS	NBDZ		# (GYRO PULSES)/(CS) X 2(-5)
		TC	FBIASSUB	# +(NBDZ)(DELTAT)	(GYRO PULSES) X 2(+14)
## Page 316
		CCS	GCOMPSW		# ARE GYRO COMMANDS GREATER THAN 2 PULSES
		TCF	1/GYRO		# YES
		TCF	ENDOFJOB	# NO

## Page 317
FBIASSUB	XCH	Q
		TS	BUF +1

		CA	Q		# NBD SCALED (GYRO PULSES)/(CS) X 2(-5)
		EXTEND
		MP	MPAC		# DELTAT SCALED (CS) X 2(+19)
		INDEX	BUF
		DAS	GCOMP		# HI(NBD)(DELTAT)	(GYRO PULSES) X 2(+14)

		CA	Q		# NOW FRACTIONAL PART
		EXTEND
		MP	MPAC +1
		TS	L
		CAF	ZERO
		INDEX	BUF
		DAS	GCOMP		# (NBD)(DELTAT)		(GYRO PULSES) X 2(+14)

		TCF	DRFTSUB2	# CHECK MAGNITUDE OF COMPENSATION

LASTBIAS	TC	BANKCALL
		CADR	PIPUSE

		CCS	GCOMPSW		# BYPASS IF GCOMPSW NEGATIVE
		TCF	+3
		TCF	+2
		TCF	ENDOFJOB

		CAF	PRIO31		# 2 SECONDS SCALED (CS) X 2(+8)
		XCH	1/PIPADT
		COM
		AD	PIPTIME1 +1	# TIME AT PIPA1 =0
		TCF	NBD2

90SECS		DEC	9000
20DEGS		DEC	7199
