#include "recognize.h"
#include "photo_info.h"
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include "math.h"

using namespace cv;

Recognize::Recognize(QObject *parent) :
    QObject(parent)
{
    photoInfo.angle = 0;
    photoInfo.offsetX = 0;
    photoInfo.offsetY = 0;
    this->photoInfo.xOnLatScaling = 1920 * 1080;
}

void Recognize::calcOffset(const QString& filename1,
                           const QString& filename2)
{
    Mat frame1, frame2;
    frame1 = imread(filename1.toUtf8().constData());
    frame2 = imread(filename2.toUtf8().constData());
    float oldSquare = this->photoInfo.xOnLatScaling;
    try {
        photoInfo = calc_photo_info(frame1, frame2, photoInfo, "0");
    } catch(...) {

    }
    this->mLat -= photoInfo.offsetY * this->mHeight / 111132.0 / 1080.0 * 0.86 * 32/*!!*/; //TODO: mull on initial degrees
    this->mLon += photoInfo.offsetX * this->mHeight / 78847.0 / 1920.0 * 3.48 * 54;
    photoInfo.offsetX = 0;
    photoInfo.offsetY = 0;
    this->mHeight = this->mHeight * sqrt(float(oldSquare)) / sqrt(float(this->photoInfo.xOnLatScaling));
    this->mYaw = -1 * photoInfo.angle;
}
