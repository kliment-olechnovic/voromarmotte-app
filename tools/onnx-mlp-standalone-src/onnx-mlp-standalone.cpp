#include <onnxruntime_cxx_api.h>
#include <iostream>
#include <fstream>
#include <vector>
#include <iomanip>
#include <cmath>

int main(int argc, char* argv[])
{
	const char* onnx_path = argv[1];
	const char* data_path = argv[2];

	Ort::Env env(ORT_LOGGING_LEVEL_ERROR, "mlp");
	Ort::SessionOptions so;
	so.SetGraphOptimizationLevel(GraphOptimizationLevel::ORT_ENABLE_ALL);

	Ort::Session sess(env, onnx_path, so);
	Ort::AllocatorWithDefaultOptions allocator;

	Ort::AllocatedStringPtr in_name_alloc  = sess.GetInputNameAllocated(0, allocator);
	Ort::AllocatedStringPtr out_name_alloc = sess.GetOutputNameAllocated(0, allocator);
	const char* input_name  = in_name_alloc.get();
	const char* output_name = out_name_alloc.get();

	std::ifstream f(data_path, std::ios::binary);
	f.seekg(0, std::ios::end);
	size_t nbytes = static_cast<size_t>(f.tellg());
	f.seekg(0, std::ios::beg);
	std::vector<float> features(nbytes / sizeof(float));
	f.read(reinterpret_cast<char*>(features.data()), nbytes);

	Ort::TypeInfo type_info = sess.GetInputTypeInfo(0);
	Ort::ConstTensorTypeAndShapeInfo tensor_info = type_info.GetTensorTypeAndShapeInfo();
	std::vector<int64_t> in_dims = tensor_info.GetShape();
	int64_t n_cols = in_dims.back();
	int64_t n_rows = static_cast<int64_t>(features.size()) / n_cols;
	std::vector<int64_t> input_shape;
	input_shape.push_back(n_rows);
	input_shape.push_back(n_cols);

	Ort::MemoryInfo mem = Ort::MemoryInfo::CreateCpu(OrtArenaAllocator, OrtMemTypeDefault);
	Ort::Value input_tensor = Ort::Value::CreateTensor<float>(mem, features.data(), features.size(), input_shape.data(), input_shape.size());

	std::vector<const char*> in_names(1, input_name);
	std::vector<const char*> out_names(1, output_name);
	Ort::RunOptions run_opts;
	std::vector<Ort::Value> outputs = sess.Run(run_opts, in_names.data(), &input_tensor, 1, out_names.data(), 1);

	Ort::Value& out_tensor = outputs[0];
	float* out_data = out_tensor.GetTensorMutableData<float>();
	Ort::TensorTypeAndShapeInfo out_tsi = out_tensor.GetTensorTypeAndShapeInfo();
	size_t out_count = out_tsi.GetElementCount();

	for (size_t i = 0; i < out_count; ++i)
	{
		float x = out_data[i];
		out_data[i] = 1.0f / (1.0f + std::exp(-x));
	}

	std::cout << "predicted_probability_to_persist\n";
	std::cout.setf(std::ios::fmtflags(0), std::ios::floatfield);
	std::cout << std::setprecision(10);
	for (size_t i = 0; i < out_count; ++i)
	{
		std::cout << out_data[i] << '\n';
	}

	return 0;
}
