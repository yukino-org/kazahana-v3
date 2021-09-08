import canvas from "canvas";

export interface GetModifiedOptions {
    size: number;
    backgroundColor: string;
    borderRadius: number;
    borderPadding: number;
    imagePadding: number;
}

export const getModified = async (path: string, options: Partial<GetModifiedOptions> = {}): Promise<Buffer> => {
    const {
        size = 1000,
        backgroundColor = "#FFF",
        borderRadius = 200,
        borderPadding = 0,
        imagePadding = 160,
    } = options;
    
    const image = canvas.createCanvas(size, size);
    const ctx = image.getContext("2d");

    const bgSize = size - borderPadding;
    ctx.beginPath();
    ctx.moveTo(borderPadding, borderPadding + borderRadius);
    ctx.lineTo(borderPadding, borderPadding + bgSize - borderRadius);
    ctx.arcTo(borderPadding, borderPadding + bgSize, borderPadding + borderRadius, borderPadding + bgSize, borderRadius);
    ctx.lineTo(borderPadding + bgSize - borderRadius, borderPadding + bgSize);
    ctx.arcTo(borderPadding + bgSize, borderPadding + bgSize, borderPadding + bgSize, borderPadding + bgSize - borderRadius, borderRadius);
    ctx.lineTo(borderPadding + bgSize, borderPadding + borderRadius);
    ctx.arcTo(borderPadding + bgSize, borderPadding, borderPadding + bgSize - borderRadius, borderPadding, borderRadius);
    ctx.lineTo(borderPadding + borderRadius, borderPadding);
    ctx.arcTo(borderPadding, borderPadding, borderPadding, borderPadding + borderRadius, borderRadius);

    ctx.fillStyle = backgroundColor;
    ctx.fill();
    ctx.closePath();

    const iconSize = size - (imagePadding * 2);
    ctx.drawImage(await canvas.loadImage(path), imagePadding, imagePadding, iconSize, iconSize);

    return image.toBuffer();
}