/**
 * @file colorspace.h
 * @author Pascal Getreuer 2005-2010 <getreuer@gmail.com>
 */
#ifndef _COLORSPACE_H_
#define _COLORSPACE_H_

/** @brief Datatype to use for representing real numbers
 * Set this typedef to either double or float depending on the application.
 */
typedef double num;


/** @brief XYZ color of the D65 white point */
#define WHITEPOINT_X	0.950456
#define WHITEPOINT_Y	1.0
#define WHITEPOINT_Z	1.088754



/** @brief struct for representing a color transform */
typedef struct
{
	int NumStages;
	void (*Fun[2])(num*, num*, num*, num, num, num);
} colortransform;

int GetColorTransform(colortransform *Trans, const char *TransformString);
void ApplyColorTransform(colortransform Trans,
	num *D0, num *D1, num *D2, num S0, num S1, num S2);

void Rgb2Yuv(num *Y, num *U, num *V, num R, num G, num B);
void Yuv2Rgb(num *R, num *G, num *B, num Y, num U, num V);
void Rgb2Ycbcr(num *Y, num *Cb, num *Cr, num R, num G, num B);
void Rgb2Ycbcrf(float *Y, float *Cb, float *Cr, float R, float G, float B);
void Ycbcr2Rgb(num *R, num *G, num *B, num Y, num Cb, num Cr);
void Ycbcr2Rgbf(float *R, float *G, float *B, float Y, float Cr, float Cb);
void Rgb2Jpegycbcr(num *R, num *G, num *B, num Y, num Cb, num Cr);
void Jpegycbcr2Rgb(num *R, num *G, num *B, num Y, num Cb, num Cr);
void Rgb2Ypbpr(num *Y, num *Pb, num *Pr, num R, num G, num B);
void Ypbpr2Rgb(num *R, num *G, num *B, num Y, num Pb, num Pr);
void Rgb2Ydbdr(num *Y, num *Db, num *Dr, num R, num G, num B);
void Ydbdr2Rgb(num *R, num *G, num *B, num Y, num Db, num Dr);
void Rgb2Yiq(num *Y, num *I, num *Q, num R, num G, num B);
void Yiq2Rgb(num *R, num *G, num *B, num Y, num I, num Q);

void Rgb2Hsv(num *H, num *S, num *V, num R, num G, num B);
void Rgb2Hsvf(float *H, float *S, float *V, float R, float G, float B);
void Rgb2Hf(float *H, float R, float G, float B);
//r,g,b is 0-255
void RGB2Hsvf(float *H, float *S, float *V, unsigned char r, unsigned char g, unsigned char b);
void Hsv2Rgb(num *R, num *G, num *B, num H, num S, num V);
void Rgb2Hsl(num *H, num *S, num *L, num R, num G, num B);
void Hsl2Rgb(num *R, num *G, num *B, num H, num S, num L);
void Rgb2Hsi(num *H, num *S, num *I, num R, num G, num B);
void Hsi2Rgb(num *R, num *G, num *B, num H, num S, num I);

void Rgb2Xyz(num *X, num *Y, num *Z, num R, num G, num B);
void Rgb2Xyzf(float *X, float *Y, float *Z, float R, float G, float B);
void Xyz2Rgb(num *R, num *G, num *B, num X, num Y, num Z);
void Xyz2Lab(num *L, num *a, num *b, num X, num Y, num Z);
void Xyz2Labf(float *L, float *a, float *b, float X, float Y, float Z);
void Lab2Xyz(num *X, num *Y, num *Z, num L, num a, num b);
void Xyz2Luv(num *L, num *u, num *v, num X, num Y, num Z);
void Xyz2Luvf(float *L, float *u, float *v, float X, float Y, float Z);
void Luv2Xyz(num *X, num *Y, num *Z, num L, num u, num v);
void Xyz2Lch(num *L, num *C, num *H, num X, num Y, num Z);
void Lch2Xyz(num *X, num *Y, num *Z, num L, num C, num H);
void Xyz2Cat02lms(num *L, num *M, num *S, num X, num Y, num Z);
void Cat02lms2Xyz(num *X, num *Y, num *Z, num L, num M, num S);

void Rgb2Lab(num *L, num *a, num *b, num R, num G, num B);
void Rgb2Labf(float *L, float *a, float *b, float R, float G, float B);
void Lab2Rgb(num *R, num *G, num *B, num L, num a, num b);
void Rgb2Luv(num *L, num *u, num *v, num R, num G, num B);
void Rgb2Luvf(float *L, float *u, float *v, float R, float G, float B);
void Luv2Rgb(num *R, num *G, num *B, num L, num u, num v);
void Rgb2Lch(num *L, num *C, num *H, num R, num G, num B);
void Lch2Rgb(num *R, num *G, num *B, num L, num C, num H);
void Rgb2Cat02lms(num *L, num *M, num *S, num R, num G, num B);
void Cat02lms2Rgb(num *R, num *G, num *B, num L, num M, num S);

#endif  /* _COLORSPACE_H_ */
