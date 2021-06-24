#include <opencv2/opencv.hpp>
#include <opencv2/freetype.hpp>

using namespace cv;
using namespace std;

// Avoiding name mangling
extern "C" {
    // Attributes to prevent 'unused' function from being removed and to make it visible
    __attribute__((visibility("default"))) __attribute__((used))
    const char* version() {
        return CV_VERSION;
    }

    __attribute__((visibility("default"))) __attribute__((used))
    void add_image_mark(char* markImagePath, char* joinImagePath, char* outputImagePath, double alpha, int position, double markRatio) {
        Mat main_image, watermark;

        string file;
        double beta;
        
        main_image = imread(joinImagePath);
        watermark = imread(markImagePath);
        if (markRatio != 1) {
            // resize watermark image with ratio
            Size ratioSize = Size(watermark.rows * markRatio, watermark.cols * markRatio);
            resize(watermark, watermark, ratioSize);
        }
        Rect pos;
        switch(position) {
            case 0:
                pos = Rect(
                    0,
                    0,
                    watermark.size().width,
                    watermark.size().height);
                break;
            case 1:
                pos = Rect(
                    main_image.size().width - watermark.size().width,
                    0,
                    watermark.size().width,
                    watermark.size().height);
                break;
            case 2:
                pos = Rect(
                    0,
                    main_image.size().height - watermark.size().height,
                    watermark.size().width,
                    watermark.size().height);
                break;
            case 3:
                pos = Rect(
                    main_image.size().width - watermark.size().width,
                    main_image.size().height - watermark.size().height,
                    watermark.size().width,
                    watermark.size().height);
                break;
            case 4:
                pos = Rect(
                    (main_image.size().width - watermark.size().width) / 2,
                    (main_image.size().height - watermark.size().height) / 2,
                    watermark.size().width,
                    watermark.size().height);
                break;

        }
        // set up alpha
        beta = 1 - alpha;

        addWeighted(main_image(pos), alpha, watermark, beta, 0.0, main_image(pos));
        imwrite(outputImagePath, main_image);
    }

    __attribute__((visibility("default"))) __attribute__((used))
    void add_text_mark(char* text, char* joinImagePath, char* outputImagePath, double alpha, int position) {
        Mat main_image, text_image;
        main_image = imread(joinImagePath);

        FreeType2 ft2 = freetype::createFreeType2();

        // text params
        int font = FONT_HERSHEY_SIMPLEX;
        double scale = 1.5;
        int thickness = 2.5;
        int baseline = 0;

        Size textSize = getTextSize(text, font, scale, thickness, &baseline);
        baseline += thickness;

        // center the text
        Point textPoint;
        switch(position) {
            case 0:
                textPoint = Point(0, textSize.height);
                break;
            case 1:
                textPoint = Point(
                   (main_image.cols - textSize.width),
                   textSize.height);
                break;
            case 2:
                textPoint = Point(
                   0,
                   (main_image.rows - textSize.height));
                break;
            case 3:
                textPoint = Point(
                   (main_image.cols - textSize.width),
                   (main_image.rows - textSize.height));
                break;
            case 4:
                textPoint = Point(
                   (main_image.cols - textSize.width) / 2,
                   (main_image.rows + textSize.height) / 2);
                break;

        }
        
        double beta = 1 - alpha;
        putText(main_image, text, textPoint, font, scale, Scalar(255, 255, 255, 100), thickness);
        
        imwrite(outputImagePath, main_image);
    }
}
