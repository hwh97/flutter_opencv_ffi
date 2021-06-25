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
    char* add_image_mark(char* markImagePath, char* joinImagePath, char* outputImagePath, double beta, int position, double markRatio) {
        try {
            Mat main_image, watermark;

            string file;
            double alpha;

            main_image = imread(joinImagePath);
            watermark = imread(markImagePath);
            if (markRatio != 1) {
                // resize watermark image with ratio
                Size ratioSize = Size(watermark.rows * markRatio, watermark.cols * markRatio);
                resize(watermark, watermark, ratioSize);
            }
//            if (watermark.rows > main_image.rows || watermark.cols > main_image.cols) {
//                return NULL;
//            }
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
            alpha = 1 - beta;

            addWeighted(main_image(pos), alpha, watermark, beta, 0.0, main_image(pos));
            imwrite(outputImagePath, main_image);
            return outputImagePath;
        } catch(cv::Exception& e) {
            const char* err_msg = e.what();
            cerr << "cv exception caught: " << err_msg << endl;
        } catch(std::exception& e) {
            const char* err_msg = e.what();
            cerr << "std exception caught: " << err_msg << endl;
        }
        return NULL;
    }

    __attribute__((visibility("default"))) __attribute__((used))
    char* add_text_mark(char* text, char* joinImagePath, char* outputImagePath, int position, double scale, double thickness, int colorR, int colorG, int colorB) {
        try {
            Mat main_image, text_image;
            main_image = imread(joinImagePath);

            // text params
            int font = FONT_HERSHEY_SIMPLEX;
//            double scale = 1;
//            int thickness = 1.2;
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
                       main_image.cols - textSize.width,
                       textSize.height);
                    break;
                case 2:
                    textPoint = Point(
                       0,
                       main_image.rows - baseline);
                    break;
                case 3:
                    textPoint = Point(
                       main_image.cols - textSize.width,
                       main_image.rows - baseline);
                    break;
                case 4:
                    textPoint = Point(
                       (main_image.cols - textSize.width) / 2,
                       (main_image.rows + textSize.height) / 2);
                    break;

            }
            putText(main_image, text, textPoint, font, scale, Scalar(colorB, colorG, colorR), thickness, LINE_AA);
            imwrite(outputImagePath, main_image);
            return outputImagePath;
        } catch(cv::Exception& e) {
            const char* err_msg = e.what();
            cerr << "cv exception caught: " << err_msg << endl;
        } catch(std::exception& e) {
            const char* err_msg = e.what();
            cerr << "std exception caught: " << err_msg << endl;
        }
        return NULL;
    }
}