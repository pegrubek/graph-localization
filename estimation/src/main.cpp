
#include <gtsam/geometry/Pose2.h>
#include <gtsam/inference/Symbol.h>
#include <gtsam/linear/NoiseModel.h>
#include <gtsam/slam/BetweenFactor.h>
#include <gtsam/slam/PriorFactor.h>
#include <gtsam/nonlinear/LevenbergMarquardtOptimizer.h>
#include <gtsam/nonlinear/NonlinearFactorGraph.h>
#include <gtsam/nonlinear/Values.h>

#include <iostream>

using namespace gtsam;

int main() {
    // Define the pose variables.
    const Key x0 = Symbol('x', 0);
    const Key x1 = Symbol('x', 1);
    const Key x2 = Symbol('x', 2);

    // Create the factor graph.
    NonlinearFactorGraph graph;

    // Noise models use standard deviations:
    // sigma_x, sigma_y, sigma_theta.
    const auto priorNoise = noiseModel::Diagonal::Sigmas(
        (Vector(3) << 0.01, 0.01, 0.01).finished()
    );

    const auto odometryNoise = noiseModel::Diagonal::Sigmas(
        (Vector(3) << 0.2, 0.2, 0.1).finished()
    );

    const auto closureNoise = noiseModel::Diagonal::Sigmas(
        (Vector(3) << 0.1, 0.1, 0.05).finished()
    );

    // Fix the initial pose near the origin.
    graph.add(PriorFactor<Pose2>(
        x0,
        Pose2(0.0, 0.0, 0.0),
        priorNoise
    ));

    // Relative-motion measurement x0 -> x1.
    graph.add(BetweenFactor<Pose2>(
        x0,
        x1,
        Pose2(1.1, 0.0, 0.0),
        odometryNoise
    ));

    // Relative-motion measurement x1 -> x2.
    graph.add(BetweenFactor<Pose2>(
        x1,
        x2,
        Pose2(1.1, 0.1, 0.0),
        odometryNoise
    ));

    // Additional relative-pose measurement x0 -> x2.
    // This disagrees slightly with accumulated odometry.
    graph.add(BetweenFactor<Pose2>(
        x0,
        x2,
        Pose2(2.0, 0.0, 0.0),
        closureNoise
    ));

    // Initial estimates for all variables.
    Values initial;
    initial.insert(x0, Pose2(0.0, 0.0, 0.0));
    initial.insert(x1, Pose2(1.0, 0.0, 0.0));
    initial.insert(x2, Pose2(2.0, 0.0, 0.0));

    std::cout << "Initial error: "
              << graph.error(initial) << '\n';

    // Optimize the graph.
    LevenbergMarquardtOptimizer optimizer(graph, initial);
    Values result = optimizer.optimize();

    std::cout << "Final error: "
              << graph.error(result) << '\n';

    // Print the optimized poses.
    for (const Key key : {x0, x1, x2}) {
        const Pose2& pose = result.at<Pose2>(key);

        std::cout
            << Symbol(key)
            << ": x=" << pose.x()
            << ", y=" << pose.y()
            << ", theta=" << pose.theta()
            << '\n';
    }

    return 0;
}
