#include <opencv2/opencv.hpp>

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
    void add_image_mask(char* markImagePath, char* joinImagePath, char* outputImagePath, double alpha, int position, double markRatio) {
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
        }
        // set up alpha
        beta = 1 - alpha;

        addWeighted(main_image(pos), alpha, watermark, beta, 0.0, main_image(pos));
        imwrite(outputImagePath, main_image);
    }

    __attribute__((visibility("default"))) __attribute__((used))
    void add_text_mask(char* text, char* joinImagePath, double alpha) {

    }
}
