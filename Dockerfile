# Use NVIDIA CUDA as base image
FROM nvidia/cuda:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Conda
RUN curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /usr/local/miniconda && \
    rm Miniconda3-latest-Linux-x86_64.sh

# Set environment variables
ENV PATH="/usr/local/miniconda/bin:${PATH}"
RUN echo ". /usr/local/miniconda/etc/profile.d/conda.sh" >> ~/.bashrc

# Clone repository and set up environment
RUN git clone https://github.com/<username>/babydoctor.git ~/git/BabyDoctor
RUN conda env create -f ~/git/BabyDoctor/llmenv.yaml
RUN echo "source activate llmforbio" >> ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"

# Activate conda environment
RUN echo "conda activate llmforbio" >> ~/.bashrc

# Install additional Python packages
RUN /bin/bash -c "source activate llmforbio && MAX_JOBS=8 python3 -m pip install flash-attn"

# Download dataset
RUN git clone https://github.com/razorx89/roco-dataset ~/roco-dataset && \
    cd ~/roco-dataset && \
    python3 scripts/fetch.py && \
    cd -

# Prepare training data
RUN python3 ~/git/BabyDoctor/scripts/massage_data.py

# Copy fine-tuning script
COPY ./finetune.sh ~/finetune.sh

# Start fine-tuning
RUN /bin/bash -c "source activate llmforbio && chmod +x ~/finetune.sh && ~/finetune.sh"

# Copy inference script
COPY ./inference.sh ~/inference.sh

# Modify and run inference script
RUN chmod +x ~/inference.sh

# Expose any necessary ports
# EXPOSE <port_number>

# Define default command to run when the container starts
CMD ["/bin/bash"]
