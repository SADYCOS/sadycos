//
// Created by Jan_L on 08.06.2026.
//
#include "mex.hpp"
#include "mexAdapter.hpp"

#include <cstdlib>
#include <exception>
#include <memory>
#include <stdexcept>
#include <string>
#include <vector>
#include <unordered_map>
#include <format>
#include <array>
#include <glm/glm.hpp>

#include "core.h"
#include "sentman.h"
#include "rotatable_mesh_satellite.h"
#include "shading_pipeline.h"
#include "shading_algorithm_factory.h"
#include "hybrid_aero_load_calculator.h"
#include "show_mesh.h"

#define LEVEL_ERROR 2
#define LEVEL_WARN 1
#define LEVEL_INFO 0

// INFO logs route through the (slow) MATLAB Engine API on every call, so they're off
// by default. Runtime (not compile-time) so a single build serves both cases: set
// MEX_GATEWAY_LOG_LEVEL=INFO in the environment before starting MATLAB to enable them.
int log_level() {
    static const int level = []() {
        const char* env = std::getenv("MEX_GATEWAY_LOG_LEVEL");
        return (env && std::string(env) == "INFO") ? LEVEL_INFO : LEVEL_WARN;
    }();
    return level;
}
#define LOG(level, msg) do { if ((level) >= log_level()) { log((level), std::string(msg), __LINE__); } } while (0)

class MatlabLogger : public matlab::mex::Function {
public:
    MatlabLogger() : matlab_ptr_(getEngine()) {}

    void log(int level, const std::string& msg, int line) {
        switch (level) {
            case LEVEL_INFO: info(msg, line); break;
            case LEVEL_WARN: warning(msg, line); break;
            case LEVEL_ERROR: error(msg, line); break;
            default: warning("Unknown log level: " + std::to_string(level), __LINE__); break;
        }
    }

private:
    void info(const std::string& msg, int line) {
        matlab_ptr_->feval(u"disp", 0, std::vector<matlab::data::Array>({factory_.createScalar("[Info] [Line: " + std::to_string(line) + "] " + msg)}));
    }

    void warning(const std::string& msg, int line) {
        matlab_ptr_->feval(u"disp", 0, std::vector<matlab::data::Array>({factory_.createScalar("[Warn] [Line: " + std::to_string(line) + "] " + msg)}));
    }

    void error(const std::string& msg, int line) {
        matlab_ptr_->feval(u"disp", 0, std::vector<matlab::data::Array>({factory_.createScalar("[Error] [Line: " + std::to_string(line) + "] " + msg)}));
    }

    std::shared_ptr<matlab::engine::MATLABEngine> matlab_ptr_;
    matlab::data::ArrayFactory factory_;
};


class MexFunction : public MatlabLogger {
public:
    MexFunction(): matlab_ptr(matlab::mex::Function::getEngine()) {}

    void operator()(matlab::mex::ArgumentList outputs, matlab::mex::ArgumentList inputs) {
        try {
            validate_input_size_min(inputs, 1);
            validate_argument(inputs, 0, "string", 1);
            // split string cmd in class and cmd
            const std::string cmd_string = inputs[0][0];
            size_t dot = cmd_string.find('.');
            std::string cls = cmd_string.substr(0, dot);
            std::string cmd = (dot != std::string::npos) ? cmd_string.substr(dot + 1) : "";
            LOG(LEVEL_INFO,"Received command: " + cmd + " for class: " +cls);
            if (cls == "Sentman") {
                if (cmd == "new") {
                    LOG(LEVEL_INFO, "Creating new Sentman instance.");
                    validate_input_size_min(inputs, 2);
                    validate_output_size(outputs, 1);
                    validate_argument(inputs, 1, "int", 1);

                    const int temperature_ratio_method = inputs[1][0];
                    sentman_map.insert({sentman_max_id, std::make_unique<Sentman>(temperature_ratio_method)});
                    outputs[0] = factory.createScalar<int>(sentman_max_id);
                    sentman_max_id++;
                    return;
                }
                if (cmd == "calc_aero_force_torque") {
                    validate_input_size(inputs, 8);
                    validate_output_size(outputs, 2);
                    validate_argument(inputs, 1, "int", 1);
                    validate_argument(inputs, 2, "double", 1);
                    validate_argument(inputs, 3, "double", 3);
                    validate_argument(inputs, 4, "double", 3);
                    validate_argument(inputs, 5, "double", 3);
                    validate_argument(inputs, 6, "double", 1);
                    validate_argument(inputs, 7, "int", 1);

                    const int handle = inputs[1][0];
                    const int aero_cond_handle = inputs[7][0];
                    Sentman* sentman = sentman_map.at(handle).get();
                    AeroConditions&  aero_conditions = *aero_conditions_map.at(aero_cond_handle);

                    const float area__m2 = inputs[2][0];
                    const glm::vec3 normal(inputs[3][0], inputs[3][1], inputs[3][2]);
                    const glm::vec3 centroid__m(inputs[4][0], inputs[4][1], inputs[4][2]);
                    const glm::vec3 v_rel__m_per_s(inputs[5][0], inputs[5][1], inputs[5][2]);
                    const float surf_temp__K = inputs[6][0];

                    glm::vec3 aero_force__N(0.0f, 0.0f, 0.0f);
                    glm::vec3 aero_torque__Nm(0.0f, 0.0f, 0.0f);

                    sentman->calc_aero_force_and_torque(
                        area__m2,
                        normal,
                        centroid__m,
                        v_rel__m_per_s,
                        surf_temp__K,
                        aero_conditions,
                        aero_force__N,
                        aero_torque__Nm
                    );

                    outputs[0] = factory.createArray({3}, {aero_force__N.x, aero_force__N.y, aero_force__N.z});
                    outputs[1] = factory.createArray({3}, {aero_torque__Nm.x, aero_torque__Nm.y, aero_torque__Nm.z});
                    return;
                }
                if (cmd == "delete") {
                    validate_input_size(inputs, 2);
                    validate_output_size(outputs, 0);
                    validate_argument(inputs, 1, "int", 1);
                    const int id = inputs[1][0];
                    sentman_map.erase(id);
                    return;
                }
            }
            if (cls == "AeroCond") {
                if (cmd == "new") {
                    LOG(LEVEL_INFO, "Creating new AeroConditions instance.");
                    validate_input_size_min(inputs, 5);
                    validate_argument(inputs, 1, "double", 1);
                    validate_argument(inputs, 2, "double", 1);
                    validate_argument(inputs, 3, "double", 1);
                    validate_argument(inputs, 4, "double", 1);

                    float density__kg_per_m3 = inputs[1][0];
                    float temperature__K = inputs[2][0];
                    float particle_mass__kg = inputs[3][0];
                    float alpha_e = inputs[4][0];

                    aero_conditions_map.insert(
                        {aero_conditions_max_id, std::make_unique<AeroConditions>(
                            density__kg_per_m3,
                            temperature__K,
                            particle_mass__kg,
                            alpha_e)}
                        );
                    outputs[0] = factory.createScalar<int>(aero_conditions_max_id);
                    aero_conditions_max_id++;
                    return;
                }
                if (cmd == "delete") {
                    validate_input_size(inputs, 2);
                    validate_output_size(outputs, 0);
                    validate_argument(inputs, 1, "int", 1);
                    const int id = inputs[1][0];
                    aero_conditions_map.erase(id);
                    return;
                }
            }
            if (cls=="Satellite") {
                if (cmd == "new") {
                    LOG(LEVEL_INFO, "Creating new Satellite instance.");
                    validate_input_size(inputs, 2);
                    validate_output_size(outputs, 1);
                    validate_argument(inputs, 1, "string", 1);
                    const std::string satellite_path = inputs[1][0];

                    satellite_map.insert({satellite_max_id, std::make_unique<RotatableMeshSatellite>(satellite_path)});
                    outputs[0] = factory.createScalar<int>(satellite_max_id);
                    satellite_max_id++;
                    return;
                }
                if (cmd=="turn_surface_around_axis") {
                    validate_input_size(inputs, 6);
                    validate_output_size(outputs, 0);
                    validate_argument(inputs, 1, "int", 1);
                    validate_argument(inputs, 2, "int", 1);
                    validate_argument(inputs, 3, "double", 1);
                    validate_argument(inputs, 4, "double", 3);
                    validate_argument(inputs, 5, "double", 3);

                    const int id = inputs[1][0];
                    RotatableMeshSatellite* satellite = satellite_map.at(id).get();
                    std::array<float, 3> origin{{inputs[4][0], inputs[4][1], inputs[4][2]}};
                    std::array<float, 3> axis{{inputs[5][0], inputs[5][1], inputs[5][2]}};
                    satellite->turn_surface_around_axis(inputs[2][0], inputs[3][0], origin, axis);
                    return;
                }
                if (cmd=="get_vertices") {
                    validate_input_size(inputs, 2);
                    validate_output_size(outputs, 1);
                    validate_argument(inputs, 1, "int", 1);
                    const int id = inputs[1][0];
                    RotatableMeshSatellite* satellite = satellite_map.at(id).get();
                    std::span<const float> vertices = satellite->get_vertices();
                    outputs[0] = factory.createArray({vertices.size()}, vertices.begin(), vertices.end());
                    return;
                }
                if (cmd=="get_num_triangles") {
                    validate_input_size(inputs, 2);
                    validate_output_size(outputs, 1);
                    validate_argument(inputs, 1, "int", 1);
                    const int id = inputs[1][0];
                    RotatableMeshSatellite* satellite = satellite_map.at(id).get();
                    const unsigned int num_triangles = satellite->get_num_triangles();
                    outputs[0] = factory.createScalar<unsigned int>(num_triangles);
                    return;
                }
                if (cmd == "delete") {
                    validate_input_size(inputs, 2);
                    validate_output_size(outputs, 0);
                    validate_argument(inputs, 1, "int", 1);
                    const int id = inputs[1][0];
                    satellite_map.erase(id);
                    return;
                }
            }
            if (cls == "Shading") {
                if (cmd == "new") {
                    LOG(LEVEL_INFO, "Creating new Shading instance.");
                    validate_input_size(inputs, 4);
                    validate_output_size(outputs, 1);
                    validate_argument(inputs, 1, "int", 1);
                    validate_argument(inputs, 2, "int", 1);
                    validate_argument(inputs, 3, "int", 1);

                    const int id = inputs[1][0];
                    RotatableMeshSatellite& satellite = *satellite_map.at(id);
                    const int shading_key = inputs[2][0];
                    ShadingAlgorithmType algorithm_type;
                    switch (shading_key) {
                        case 1:
                            algorithm_type = ShadingAlgorithmType::Binary;
                            break;
                        case 2:
                            algorithm_type = ShadingAlgorithmType::CoP;
                            break;
                        default:
                            LOG(LEVEL_ERROR, "Unknown shading algorithm type: " + std::to_string(shading_key));
                            throw std::invalid_argument(std::string("Unknown shading algorithm type: ") + std::to_string(shading_key));
                    };
                    shading_pipeline_map.insert({shading_pipeline_max_id,
                                                std::make_unique<ShadingPipeline>(satellite,algorithm_type, inputs[3][0])});
                    outputs[0] = factory.createScalar<int>(shading_pipeline_max_id);
                    shading_pipeline_max_id++;
                    return;
                }
                if (cmd=="shade"){
                    validate_input_size(inputs, 3);
                    validate_output_size(outputs, 1);
                    validate_argument(inputs, 1, "int", 1);
                    validate_argument(inputs, 2, "double", 3);

                    const int id = inputs[1][0];
                    ShadingPipeline* pipeline = shading_pipeline_map.at(id).get();

                    glm::vec3 velocity__m_per_s(inputs[2][0], inputs[2][1], inputs[2][2]);
                    std::vector<float> triangle_visibility = pipeline->shade(glm::normalize(velocity__m_per_s));

                    outputs[0] = factory.createArray({triangle_visibility.size()}, triangle_visibility.begin(), triangle_visibility.end());
                    return;
                }
                if (cmd=="delete") {
                    validate_input_size(inputs, 2);
                    validate_output_size(outputs, 0);
                    validate_argument(inputs, 1, "int", 1);
                    const int id = inputs[1][0];
                    shading_pipeline_map.erase(id);
                    return;
                }
            }
            if (cls =="HybridAeroLoadCalculator") {
                if (cmd == "new") {
                    validate_input_size(inputs, 4);
                    validate_output_size(outputs, 1);
                    validate_argument(inputs, 1, "int", 1);
                    validate_argument(inputs, 2, "int", 1);
                    validate_argument(inputs, 3, "int", 1);

                    const int satellite_id = inputs[1][0];
                    const int shading_pipeline_id = inputs[2][0];
                    const int gsi_id = inputs[3][0];

                    hybrid_aero_load_calculator_map.insert(
                        {hybrid_aero_max_id,
                        std::make_unique<HybridForceTorqueCalculator>(
                            *satellite_map.at(satellite_id),
                            *shading_pipeline_map.at(shading_pipeline_id),
                            *sentman_map.at(gsi_id)
                        )}
                    );

                    outputs[0] = factory.createScalar<int>(hybrid_aero_max_id);
                    hybrid_aero_max_id++;
                    return;
                }
                if (cmd=="calc_aero_load") {
                    validate_input_size(inputs, 5);
                    validate_output_size(outputs, 2);
                    validate_argument(inputs, 1, "int", 1);
                    validate_argument(inputs, 2, "double", 3);
                    validate_argument(inputs, 3, "double", 1);
                    validate_argument(inputs, 4, "int", 1);

                    const int aero_cond_id = inputs[4][0];
                    const int id = inputs[1][0];
                    HybridForceTorqueCalculator* calculator = hybrid_aero_load_calculator_map.at(id).get();
                    AeroConditions&  aero_conditions = *aero_conditions_map.at(aero_cond_id);

                    glm::vec3 velocity__m_per_s(inputs[2][0], inputs[2][1], inputs[2][2]);
                    const float surface_temp__K = inputs[3][0];
                    glm::vec3 torque__Nm(0.0f, 0.0f, 0.0f);
                    glm::vec3 force__N(0.0f, 0.0f, 0.0f);
                    calculator->calc_aero_torque_force(velocity__m_per_s, surface_temp__K, aero_conditions, torque__Nm, force__N);
                    outputs[0] = factory.createArray({3}, {force__N.x, force__N.y, force__N.z});
                    outputs[1] = factory.createArray({3}, {torque__Nm.x, torque__Nm.y, torque__Nm.z});
                    return;
                }
                if (cmd=="delete") {
                    validate_input_size(inputs, 2);
                    validate_output_size(outputs, 0);
                    validate_argument(inputs, 1, "int", 1);
                    const int id = inputs[1][0];
                    hybrid_aero_load_calculator_map.erase(id);
                    return;
                }
            }
            if (cls == "Visualization") {
                if (cmd == "show_mesh") {
                    validate_input_size(inputs, 4);
                    validate_output_size(outputs, 0);
                    validate_argument(inputs, 1, "int", 1);
                    validate_argument(inputs, 3, "double", 3);

                    const int satellite_id = inputs[1][0];
                    RotatableMeshSatellite& satellite = *satellite_map.at(satellite_id);
                    validate_argument(inputs, 2, "float", satellite.get_num_triangles());

                    matlab::data::TypedArray<float> const typed_array = inputs[2];
                    std::vector<float> triangle_visibility(typed_array.begin(), typed_array.end());
                    glm::vec3 velocity__m_per_s(inputs[3][0], inputs[3][1], inputs[3][2]);

                    ShowMeshWithShadingAndWind(satellite, triangle_visibility, velocity__m_per_s);
                    return;
                }
            }
            LOG(LEVEL_ERROR, "Unknown command: " + cmd + " for class: " + cls);
            throw std::invalid_argument("Unknown command: " + cmd + " for class: " + cls);
        } catch (const std::exception& e) {
            // Log the error to MATLAB console and rethrow so MATLAB receives a proper error
            LOG(LEVEL_ERROR, e.what());
            throw; // propagate the exception back to MATLAB instead of silently returning with no outputs
        }
    }

private:
    // Extracted utility checkers to keep subclass neat
    static bool is_int(matlab::mex::ArgumentList& inputs, int idx) {
        const matlab::data::ArrayType type = inputs[idx].getType();
        return (type == matlab::data::ArrayType::INT8 ||
                type == matlab::data::ArrayType::INT16 ||
                type == matlab::data::ArrayType::INT32 ||
                type == matlab::data::ArrayType::INT64);
    };

    static bool is_double(matlab::mex::ArgumentList& inputs, int idx) {
        return (inputs[idx].getType() == matlab::data::ArrayType::DOUBLE &&
        inputs[idx].getType() != matlab::data::ArrayType::COMPLEX_DOUBLE);
    };

    static bool is_float(matlab::mex::ArgumentList& inputs, int idx) {
        return (inputs[idx].getType() == matlab::data::ArrayType::SINGLE &&
        inputs[idx].getType() != matlab::data::ArrayType::COMPLEX_SINGLE);
    };

    static bool is_uint(matlab::mex::ArgumentList& inputs, int idx) {
        const matlab::data::ArrayType type = inputs[idx].getType();
        return (type == matlab::data::ArrayType::UINT8 ||
                type == matlab::data::ArrayType::UINT16 ||
                type == matlab::data::ArrayType::UINT32 ||
                type == matlab::data::ArrayType::UINT64);
    };

    static bool is_string(matlab::mex::ArgumentList& inputs, int idx) {
        return inputs[idx].getType() == matlab::data::ArrayType::MATLAB_STRING;

    };

    void validate_argument(matlab::mex::ArgumentList& inputs,
                           int idx,
                           const std::string& expected_type,
                           int expected_size) {
        if (expected_type == "int" && !is_int(inputs, idx)) {
            LOG(LEVEL_ERROR, std::format("Expected argument at index {} to be an integer.", idx));
            throw std::invalid_argument("Argument type mismatch: expected integer.");
        }
        if (expected_type == "double" && !is_double(inputs, idx)) {
            LOG(LEVEL_ERROR, std::format("Expected argument at index {} to be a double.", idx));
            throw std::invalid_argument("Argument type mismatch: expected double.");
        }
        if (expected_type == "float" && !is_float(inputs, idx)) {
            LOG(LEVEL_ERROR, std::format("Expected argument at index {} to be a float.", idx));
            throw std::invalid_argument("Argument type mismatch: expected float.");
        }
        if (expected_type == "uint" && !is_uint(inputs, idx)) {
            LOG(LEVEL_ERROR, std::format("Expected argument at index {} to be an unsigned integer.", idx));
            throw std::invalid_argument("Argument type mismatch: expected unsigned integer.");
        }
        if (expected_type == "string" && !is_string(inputs, idx)) {
            LOG(LEVEL_ERROR, std::format("Expected argument at index {} to be a string.", idx));
            throw std::invalid_argument("Argument type mismatch: expected string.");
        }
        if (expected_size != inputs[idx].getNumberOfElements()) {
            LOG(LEVEL_ERROR, std::format("Expected argument at index {} to have size {}, but got size {}.", idx, expected_size, inputs[idx].getNumberOfElements()));
            throw std::invalid_argument("Argument size mismatch.");
        }
    };

    void validate_input_size(matlab::mex::ArgumentList& inputs, int expected_size) {
        if (inputs.size() != expected_size) {
            LOG(LEVEL_ERROR, std::format("Expected {} input arguments, but got {}.", expected_size, inputs.size()));
            throw std::invalid_argument("Input argument count mismatch.");
        }
    };

    void validate_output_size(matlab::mex::ArgumentList& outputs, int expected_size) {
        if (outputs.size() != expected_size) {
            LOG(LEVEL_ERROR, std::format("Expected {} output arguments, but got {}.", expected_size, outputs.size()));
            throw std::invalid_argument("Output argument count mismatch.");
        }
    };

    void validate_input_size_min(matlab::mex::ArgumentList& inputs, int min_size) {
        if (inputs.size() < min_size) {
            LOG(LEVEL_ERROR, std::format("Expected at least {} input arguments, but got {}.", min_size, inputs.size()));
            throw std::invalid_argument("Not enough input arguments.");
        }
    };

    std::shared_ptr<matlab::engine::MATLABEngine> matlab_ptr;
    matlab::data::ArrayFactory factory;
    std::unordered_map<int, std::unique_ptr<Sentman>> sentman_map;
    std::unordered_map<int, std::unique_ptr<AeroConditions>> aero_conditions_map;
    std::unordered_map<int, std::unique_ptr<RotatableMeshSatellite>> satellite_map;
    std::unordered_map<int, std::unique_ptr<ShadingPipeline>> shading_pipeline_map;
    std::unordered_map<int, std::unique_ptr<HybridForceTorqueCalculator>> hybrid_aero_load_calculator_map;
    int sentman_max_id = 0;
    int aero_conditions_max_id = 0;
    int satellite_max_id = 0;
    int shading_pipeline_max_id = 0;
    int hybrid_aero_max_id = 0;
};