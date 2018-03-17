#ifndef RECOGNIZE_H
#define RECOGNIZE_H

#include <QObject>
#include "photo_info.h"


class Recognize : public QObject
{
    Q_OBJECT

public:
    Q_PROPERTY(double lat
               READ lat
               WRITE setLat
               NOTIFY latChanged)
    Q_PROPERTY(double lon
               READ lon
               WRITE setLon
               NOTIFY lonChanged)
    Q_PROPERTY(double yaw
               READ yaw
               WRITE setYaw
               NOTIFY yawChanged)
    Q_PROPERTY(double height
               READ height
               WRITE setHeight
               NOTIFY heightChanged)


    explicit Recognize(QObject *parent = 0);

    Q_INVOKABLE void calcOffset(const QString& filename1,
                                const QString& filename2);

    double lat() { return mLat; };
    double lon() { return mLon; };
    double yaw() { return mYaw; };
    double height() { return mHeight; };


public slots:
    void setLat(const double& lat) { mLat = lat; };
    void setLon(const double& lon) { mLon = lon; };
    void setYaw(const double& yaw) { mYaw = yaw; photoInfo.angle = yaw;};
    void setHeight(const double& height) { mHeight = height; };


signals:
    void latChanged(const double& lat);
    void lonChanged(const double& lon);
    void yawChanged(const double& yaw);
    void heightChanged(const double& height);

    void error(const QString& msg);

private:
    double mLat;
    double mLon;
    double mYaw;
    double mHeight;
    PhotoInfo photoInfo;
};

#endif // RECOGNIZE_H
